;;; org-upcoming-modeline-test.el --- Tests for org-upcoming-modeline

;; Copyright (C) 2023 Kevin Brubeck Unhammer

;; Author: Kevin Brubeck Unhammer <unhammer@fsfe.org>

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(require 'org-upcoming-modeline nil t)

(ert-deftest org-upcoming-modeline-format-time ()
  (let* ((org-upcoming-modeline-l10n '((tomorrow . "tomorrow")))
         (system-time-locale "C.UTF-8")
         (org-upcoming-modeline-duration-threshold 3600)
         (org-upcoming-modeline-show-seconds t)
         (now       (make-ts :hour 10 :minute 0 :second 0 :day 1 :month 1 :year 2000))
         (past90s   (ts-adjust 'second (- 90) now))
         (in90s     (ts-adjust 'second 90 now))
         (in1hour   (ts-adjust 'hour 1 now))
         (tomorrow9 (ts-adjust 'day 1 'hour (- 1) now))
         (in2days   (ts-adjust 'day 2 now))
         (in6days   (ts-adjust 'day 6 now))
         (in7days   (ts-adjust 'day 7 now))
         (in10days  (ts-adjust 'day 10 now))
         (in28days  (ts-adjust 'day 28 now))
         (in60days  (ts-adjust 'day 60 now))
         (in1year   (ts-adjust 'year 1 now)))
    (should (equal (org-upcoming-modeline--format-ts  past90s now)   "-1m30s"))
    (should (equal (org-upcoming-modeline--format-ts  in90s now)     "1m30s"))
    (should (equal (org-upcoming-modeline--format-ts  in1hour now)   "1h"))
    (should (equal (org-upcoming-modeline--format-ts  tomorrow9 now) "tomorrow 09:00"))
    (should (equal (org-upcoming-modeline--format-ts  in2days now)   "Mon 10:00"))
    (should (equal (org-upcoming-modeline--format-ts  in6days now)   "Fri 10:00"))
    (should (equal (org-upcoming-modeline--format-ts  in7days now)   "Sat 8, 10:00"))
    (should (equal (org-upcoming-modeline--format-ts  in10days now)  "Tue 11, 10:00"))
    (should (equal (org-upcoming-modeline--format-ts  in28days now)  "29 Jan 10:00"))
    (should (equal (org-upcoming-modeline--format-ts  in60days now)  "1 Mar 10:00"))
    (should (equal (org-upcoming-modeline--format-ts  in1year now)   "1 Jan 2001, 10:00"))))

(ert-deftest org-upcoming-modeline-format-time-newyear ()
  (let* ((org-upcoming-modeline-l10n '((tomorrow . "tomorrow")))
         (system-time-locale "C.UTF-8")
         (org-upcoming-modeline-duration-threshold 3600)
         (org-upcoming-modeline-show-seconds t)
         (now       (make-ts :hour 10 :minute 0 :second 0 :day 31 :month 12 :year 1999))
         (past90s   (ts-adjust 'second (- 90) now))
         (in90s     (ts-adjust 'second 90 now))
         (in1hour   (ts-adjust 'hour 1 now))
         (tomorrow9 (ts-adjust 'day 1 'hour (- 1) now))
         (in2days   (ts-adjust 'day 2 now))
         (in6days   (ts-adjust 'day 6 now))
         (in7days   (ts-adjust 'day 7 now))
         (in10days  (ts-adjust 'day 10 now))
         (in28days  (ts-adjust 'day 28 now))
         (in60days  (ts-adjust 'day 60 now))
         (in1year   (ts-adjust 'year 1 now)))
    (should (equal (org-upcoming-modeline--format-ts  past90s now)   "-1m30s"))
    (should (equal (org-upcoming-modeline--format-ts  in90s now)     "1m30s"))
    (should (equal (org-upcoming-modeline--format-ts  in1hour now)   "1h"))
    (should (equal (org-upcoming-modeline--format-ts  tomorrow9 now) "tomorrow 09:00"))
    (should (equal (org-upcoming-modeline--format-ts  in2days now)   "Sun 10:00"))
    (should (equal (org-upcoming-modeline--format-ts  in6days now)   "Thu 10:00"))
    (should (equal (org-upcoming-modeline--format-ts  in7days now)   "Fri 7, 10:00"))
    (should (equal (org-upcoming-modeline--format-ts  in10days now)  "Mon 10, 10:00"))
    (should (equal (org-upcoming-modeline--format-ts  in28days now)  "28 Jan 10:00"))
    (should (equal (org-upcoming-modeline--format-ts  in60days now)  "29 Feb 10:00"))
    (should (equal (org-upcoming-modeline--format-ts  in1year now)   "31 Dec 2000, 10:00"))))

(ert-deftest org-upcoming-modeline-format-time-without-seconds ()
  "The default drops the seconds part, but keeps bare seconds."
  (let* ((system-time-locale "C.UTF-8")
         (org-upcoming-modeline-show-seconds nil)
         (org-upcoming-modeline-duration-threshold 3600)
         (now     (make-ts :hour 10 :minute 0 :second 0 :day 1 :month 1 :year 2000))
         (past90s (ts-adjust 'second (- 90) now))
         (in45s   (ts-adjust 'second 45 now))
         (in90s   (ts-adjust 'second 90 now))
         (in1hour (ts-adjust 'hour 1 now)))
    (should (equal (org-upcoming-modeline--format-ts past90s now) "-1m"))
    (should (equal (org-upcoming-modeline--format-ts in45s now)   "45s"))
    (should (equal (org-upcoming-modeline--format-ts in90s now)   "1m"))
    (should (equal (org-upcoming-modeline--format-ts in1hour now) "1h"))
    (should (equal (org-upcoming-modeline--format-duration 3661)  "1h1m"))))

(defun org-upcoming-modeline-test--span (start-h start-m end-h end-m)
  "Item (START END MARKER) for `org-upcoming-modeline--pick'.
END is nil if END-H is nil.  MARKER is just the start hour, for readability."
  (let ((start (make-ts :hour start-h :minute start-m :second 0 :day 1 :month 1 :year 2000)))
    (list start
          (and end-h (ts-apply :hour end-h :minute end-m start))
          start-h)))

(defun org-upcoming-modeline-test--pick (items h m)
  "Readable form of `org-upcoming-modeline--pick' on ITEMS at H:M.
That is (TIME-STRING MARKER RUNNING-P), or nil if nothing was picked."
  (let ((r (org-upcoming-modeline--pick
            items
            (make-ts :hour h :minute m :second 0 :day 1 :month 1 :year 2000))))
    (and r (list (ts-format "%H:%M" (car r)) (nth 1 r) (and (nth 2 r) t)))))

(ert-deftest org-upcoming-modeline-pick-next ()
  "Without `org-upcoming-modeline-show-running', pick the earliest event."
  (let* ((org-upcoming-modeline-show-running nil)
         (items (list (org-upcoming-modeline-test--span 10 0 11 30)
                      (org-upcoming-modeline-test--span 11 30 12 30))))
    ;; The 10:00 one started 5 minutes ago, but is kept for `keep-late':
    (should (equal (org-upcoming-modeline-test--pick items 10 5) '("10:00" 10 nil)))
    (should (equal (org-upcoming-modeline-test--pick items 9 0) '("10:00" 10 nil)))
    (should-not (org-upcoming-modeline-test--pick nil 10 5))))

(ert-deftest org-upcoming-modeline-pick-running ()
  (let* ((org-upcoming-modeline-show-running t)
         (org-upcoming-modeline-switch-ahead (* 15 60))
         (org-upcoming-modeline-keep-late 900)
         (items (list (org-upcoming-modeline-test--span 10 0 11 30)
                      (org-upcoming-modeline-test--span 11 30 12 30)))
         (at (lambda (h m) (org-upcoming-modeline-test--pick items h m))))
    ;; Running: count down its end.
    (should (equal (funcall at 10 5) '("11:30" 10 t)))
    (should (equal (funcall at 11 10) '("11:30" 10 t)))
    ;; Less than switch-ahead left: hand over to the next one.
    (should (equal (funcall at 11 25) '("11:30" 11 nil)))
    ;; Nothing next: keep counting down the running one.
    (should (equal (funcall at 12 25) '("12:30" 11 t)))
    ;; All over.
    (should-not (funcall at 13 0))
    ;; Before everything: the next one, as usual.
    (should (equal (funcall at 9 0) '("10:00" 10 nil)))))

(ert-deftest org-upcoming-modeline-pick-running-no-range ()
  "Events without a time range are never \"running\", but do get `keep-late'."
  (let* ((org-upcoming-modeline-show-running t)
         (org-upcoming-modeline-keep-late 900)
         (items (list (org-upcoming-modeline-test--span 10 0 nil nil))))
    (should (equal (org-upcoming-modeline-test--pick items 10 5) '("10:00" 10 nil)))
    (should-not (org-upcoming-modeline-test--pick items 10 20))))

(ert-deftest org-upcoming-modeline-range-end ()
  (let ((start (make-ts :hour 10 :minute 0 :second 0 :day 5 :month 5 :year 2024)))
    (should (equal (ts-format "%H:%M" (org-upcoming-modeline--range-end
                                      "<2024-05-05 Sun 10:00-11:30>" start))
                   "11:30"))
    (should-not (org-upcoming-modeline--range-end "<2024-05-05 Sun 10:00>" start))
    (should-not (org-upcoming-modeline--range-end "<2024-05-05 Sun>" start))))

(provide 'org-upcoming-modeline-test)
