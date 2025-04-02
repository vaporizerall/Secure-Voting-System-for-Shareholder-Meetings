;; Shareholder Verification Contract
;; Validates voting eligibility and shares

(define-data-var admin principal tx-sender)

;; Map of shareholder addresses to number of shares
(define-map shareholders principal uint)

;; Map to track if a shareholder has been verified for current meeting
(define-map verified-shareholders principal bool)

;; Current meeting ID
(define-data-var current-meeting-id uint u0)

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Add a shareholder with their share count
(define-public (add-shareholder (shareholder principal) (shares uint))
  (begin
    (asserts! (is-admin) (err u403))
    (asserts! (> shares u0) (err u400))
    (ok (map-set shareholders shareholder shares))))

;; Update a shareholder's share count
(define-public (update-shares (shareholder principal) (new-shares uint))
  (begin
    (asserts! (is-admin) (err u403))
    (asserts! (> new-shares u0) (err u400))
    (asserts! (is-some (map-get? shareholders shareholder)) (err u404))
    (ok (map-set shareholders shareholder new-shares))))

;; Remove a shareholder
(define-public (remove-shareholder (shareholder principal))
  (begin
    (asserts! (is-admin) (err u403))
    (asserts! (is-some (map-get? shareholders shareholder)) (err u404))
    (ok (map-delete shareholders shareholder))))

;; Start a new meeting
(define-public (start-new-meeting)
  (begin
    (asserts! (is-admin) (err u403))
    ;; Clear previous verifications
    (map-delete verified-shareholders tx-sender)
    ;; Increment meeting ID
    (var-set current-meeting-id (+ (var-get current-meeting-id) u1))
    (ok (var-get current-meeting-
