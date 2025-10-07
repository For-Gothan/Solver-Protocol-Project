(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-UNAUTHORIZED (err u102))
(define-constant ERR-INVALID-AMOUNT (err u103))
(define-constant ERR-ALREADY-EXISTS (err u104))
(define-constant ERR-DEADLINE-PASSED (err u105))
(define-constant ERR-PROBLEM-CLOSED (err u106))
(define-constant ERR-SOLUTION-EXISTS (err u107))
(define-constant ERR-INSUFFICIENT-BALANCE (err u108))
(define-constant ERR-INVALID-STATUS (err u109))

(define-data-var next-problem-id uint u0)
(define-data-var next-solution-id uint u0)
(define-data-var platform-fee-rate uint u200)
(define-data-var min-reward-amount uint u100000)
(define-data-var solver-reputation-bonus uint u50)

(define-map problems
    { problem-id: uint }
    {
        creator: principal,
        title: (string-ascii 100),
        description: (string-ascii 500),
        reward-amount: uint,
        deadline: uint,
        status: (string-ascii 20),
        solution-count: uint,
        best-solution-id: (optional uint),
        created-at: uint,
        category: (string-ascii 50)
    }
)

(define-map solutions
    { solution-id: uint }
    {
        problem-id: uint,
        solver: principal,
        description: (string-ascii 1000),
        submitted-at: uint,
        votes: uint,
        is-accepted: bool,
        reward-claimed: bool
    }
)

(define-map solution-votes
    { solution-id: uint, voter: principal }
    { vote-weight: uint }
)

(define-map solver-profiles
    { solver: principal }
    {
        reputation: uint,
        problems-created: uint,
        solutions-submitted: uint,
        solutions-accepted: uint,
        total-rewards-earned: uint,
        total-rewards-distributed: uint
    }
)

(define-map problem-categories
    { category-name: (string-ascii 50) }
    { active: bool, problem-count: uint }
)

(define-map solver-stakes
    { problem-id: uint, solver: principal }
    { stake-amount: uint }
)

(define-private (get-problem-or-fail (problem-id uint))
    (ok (unwrap! (map-get? problems { problem-id: problem-id }) ERR-NOT-FOUND))
)

(define-private (get-solution-or-fail (solution-id uint))
    (ok (unwrap! (map-get? solutions { solution-id: solution-id }) ERR-NOT-FOUND))
)

(define-private (is-problem-active (problem-id uint))
    (let ((problem (unwrap! (map-get? problems { problem-id: problem-id }) false)))
        (and 
            (is-eq (get status problem) "active")
            (< stacks-block-height (get deadline problem))
        )
    )
)

(define-private (calculate-platform-fee (amount uint))
    (/ (* amount (var-get platform-fee-rate)) u10000)
)

(define-private (update-solver-stats (solver principal) (action (string-ascii 20)))
    (let ((profile (default-to
            { reputation: u0, problems-created: u0, solutions-submitted: u0, solutions-accepted: u0, total-rewards-earned: u0, total-rewards-distributed: u0 }
            (map-get? solver-profiles { solver: solver })
        )))
        (if (is-eq action "create-problem")
            (map-set solver-profiles
                { solver: solver }
                (merge profile { problems-created: (+ (get problems-created profile) u1) })
            )
            (if (is-eq action "submit-solution")
                (map-set solver-profiles
                    { solver: solver }
                    (merge profile { 
                        solutions-submitted: (+ (get solutions-submitted profile) u1),
                        reputation: (+ (get reputation profile) u10)
                    })
                )
                (if (is-eq action "accept-solution")
                    (map-set solver-profiles
                        { solver: solver }
                        (merge profile { 
                            solutions-accepted: (+ (get solutions-accepted profile) u1),
                            reputation: (+ (get reputation profile) (var-get solver-reputation-bonus))
                        })
                    )
                    true
                )
            )
        )
    )
)

(define-private (update-category-stats (category (string-ascii 50)))
    (let ((category-info (default-to { active: true, problem-count: u0 } (map-get? problem-categories { category-name: category }))))
        (map-set problem-categories
            { category-name: category }
            (merge category-info { problem-count: (+ (get problem-count category-info) u1) })
        )
    )
)

(define-public (create-problem (title (string-ascii 100)) (description (string-ascii 500)) (deadline-blocks uint) (category (string-ascii 50)))
    (let (
        (problem-id (var-get next-problem-id))
        (reward-amount (stx-get-balance tx-sender))
        (platform-fee (calculate-platform-fee reward-amount))
        (net-reward (- reward-amount platform-fee))
    )
        (asserts! (>= reward-amount (var-get min-reward-amount)) ERR-INVALID-AMOUNT)
        (asserts! (> deadline-blocks stacks-block-height) ERR-DEADLINE-PASSED)
        (try! (stx-transfer? platform-fee tx-sender CONTRACT-OWNER))
        (try! (stx-transfer? net-reward tx-sender (as-contract tx-sender)))
        (var-set next-problem-id (+ problem-id u1))
        (map-set problems
            { problem-id: problem-id }
            {
                creator: tx-sender,
                title: title,
                description: description,
                reward-amount: net-reward,
                deadline: deadline-blocks,
                status: "active",
                solution-count: u0,
                best-solution-id: none,
                created-at: stacks-block-height,
                category: category
            }
        )
        (update-solver-stats tx-sender "create-problem")
        (update-category-stats category)
        (ok problem-id)
    )
)

(define-public (submit-solution (problem-id uint) (description (string-ascii 1000)))
    (let (
        (problem (try! (get-problem-or-fail problem-id)))
        (solution-id (var-get next-solution-id))
    )
        (asserts! (is-problem-active problem-id) ERR-PROBLEM-CLOSED)
        (asserts! (is-none (map-get? solutions { solution-id: solution-id })) ERR-SOLUTION-EXISTS)
        (var-set next-solution-id (+ solution-id u1))
        (map-set solutions
            { solution-id: solution-id }
            {
                problem-id: problem-id,
                solver: tx-sender,
                description: description,
                submitted-at: stacks-block-height,
                votes: u0,
                is-accepted: false,
                reward-claimed: false
            }
        )
        (map-set problems
            { problem-id: problem-id }
            (merge problem { solution-count: (+ (get solution-count problem) u1) })
        )
        (update-solver-stats tx-sender "submit-solution")
        (ok solution-id)
    )
)

(define-public (vote-solution (solution-id uint) (weight uint))
    (let ((solution (try! (get-solution-or-fail solution-id))))
        (asserts! (> weight u0) ERR-INVALID-AMOUNT)
        (asserts! (is-none (map-get? solution-votes { solution-id: solution-id, voter: tx-sender })) ERR-ALREADY-EXISTS)
        (map-set solution-votes { solution-id: solution-id, voter: tx-sender } { vote-weight: weight })
        (map-set solutions
            { solution-id: solution-id }
            (merge solution { votes: (+ (get votes solution) weight) })
        )
        (ok true)
    )
)

(define-public (accept-solution (problem-id uint) (solution-id uint))
    (let (
        (problem (try! (get-problem-or-fail problem-id)))
        (solution (try! (get-solution-or-fail solution-id)))
    )
        (asserts! (is-eq tx-sender (get creator problem)) ERR-UNAUTHORIZED)
        (asserts! (is-eq (get problem-id solution) problem-id) ERR-NOT-FOUND)
        (asserts! (is-eq (get status problem) "active") ERR-INVALID-STATUS)
        (map-set problems
            { problem-id: problem-id }
            (merge problem { 
                status: "solved",
                best-solution-id: (some solution-id)
            })
        )
        (map-set solutions
            { solution-id: solution-id }
            (merge solution { is-accepted: true })
        )
        (update-solver-stats (get solver solution) "accept-solution")
        (ok true)
    )
)

(define-public (claim-reward (solution-id uint))
    (let ((solution (try! (get-solution-or-fail solution-id))))
        (asserts! (is-eq tx-sender (get solver solution)) ERR-UNAUTHORIZED)
        (asserts! (get is-accepted solution) ERR-INVALID-STATUS)
        (asserts! (not (get reward-claimed solution)) ERR-ALREADY-EXISTS)
        (let (
            (problem (try! (get-problem-or-fail (get problem-id solution))))
            (reward-amount (get reward-amount problem))
        )
            (try! (as-contract (stx-transfer? reward-amount tx-sender (get solver solution))))
            (map-set solutions
                { solution-id: solution-id }
                (merge solution { reward-claimed: true })
            )
            (let ((profile (default-to
                    { reputation: u0, problems-created: u0, solutions-submitted: u0, solutions-accepted: u0, total-rewards-earned: u0, total-rewards-distributed: u0 }
                    (map-get? solver-profiles { solver: (get solver solution) })
                )))
                (map-set solver-profiles
                    { solver: (get solver solution) }
                    (merge profile { total-rewards-earned: (+ (get total-rewards-earned profile) reward-amount) })
                )
            )
            (ok reward-amount)
        )
    )
)

(define-public (close-problem (problem-id uint))
    (let ((problem (try! (get-problem-or-fail problem-id))))
        (asserts! (is-eq tx-sender (get creator problem)) ERR-UNAUTHORIZED)
        (asserts! (or 
            (>= stacks-block-height (get deadline problem))
            (is-eq (get status problem) "solved")
        ) ERR-INVALID-STATUS)
        (if (is-eq (get status problem) "solved")
            (ok "already-solved")
            (begin
                (map-set problems
                    { problem-id: problem-id }
                    (merge problem { status: "closed" })
                )
                (try! (as-contract (stx-transfer? (get reward-amount problem) tx-sender (get creator problem))))
                (ok "closed-and-refunded")
            )
        )
    )
)

(define-public (update-platform-settings (fee-rate uint) (min-reward uint) (reputation-bonus uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
        (var-set platform-fee-rate fee-rate)
        (var-set min-reward-amount min-reward)
        (var-set solver-reputation-bonus reputation-bonus)
        (ok true)
    )
)

(define-read-only (get-problem (problem-id uint))
    (map-get? problems { problem-id: problem-id })
)

(define-read-only (get-solution (solution-id uint))
    (map-get? solutions { solution-id: solution-id })
)

(define-read-only (get-solver-profile (solver principal))
    (map-get? solver-profiles { solver: solver })
)

(define-read-only (get-solution-vote (solution-id uint) (voter principal))
    (map-get? solution-votes { solution-id: solution-id, voter: voter })
)

(define-read-only (get-platform-stats)
    {
        total-problems: (var-get next-problem-id),
        total-solutions: (var-get next-solution-id),
        platform-fee-rate: (var-get platform-fee-rate),
        min-reward-amount: (var-get min-reward-amount),
        reputation-bonus: (var-get solver-reputation-bonus)
    }
)

(define-read-only (get-category-info (category (string-ascii 50)))
    (map-get? problem-categories { category-name: category })
)