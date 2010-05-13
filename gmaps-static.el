;;; gmaps-static.el --- Display address on map inside an Emacs buffer

;;; Commentary:
;;
;; Usage: M-x gmaps-static-show-address
;;

;;; History:
;; 

;;; Code:

(defgroup gmaps-static nil
  "Map viewer based on Google Static Maps API."
  :prefix "gmaps-static-"
  :group 'applications)

(defcustom gmaps-static-zoom-level 13
  "Map zoom level."
  :type 'integer
  :group 'gmaps-static)

(defvar gmaps-static-api-url-scheme
  "http://maps.google.com/maps/api/staticmap?zoom=%s&markers=size:small|color:black|%s|%s&size=500x300&sensor=false"
  "Google Static Maps API URI scheme.")

(defvar gmaps-static-current-zoom-level nil
  "Current zoom level.")

(defvar gmaps-static-current-address nil
  "Current address.")

(defvar gmaps-static-mode-map
  (let ((mode-map (make-sparse-keymap)))
    (define-key mode-map (kbd "<wheel-up>") 'gmaps-static-zoom-in)
    (define-key mode-map (kbd "<wheel-down>") 'gmaps-static-zoom-out)
    (define-key mode-map (kbd "-") 'gmaps-static-zoom-out)
    (define-key mode-map (kbd "+") 'gmaps-static-zoom-out)
    mode-map)
  "Keyboard and mouse event handlers.")

(defun gmaps-static-show-address (address zoom-level)
  "Show ADDRESS on a map using Google Static Maps API.
Argument ZOOM-LEVEL defaults to `gmaps-static-zoom-level'."
  (interactive
   (list (read-string "Address: ")
         (read-number "Zoom level: " gmaps-static-zoom-level)))
  (let* ((address-hex (url-hexify-string address))
         (url (format gmaps-static-api-url-scheme zoom-level address-hex address-hex)))
    (url-retrieve url 'gmaps-static-callback (list zoom-level address))))

(defun gmaps-static-callback (&rest data)
  "Callback function for `url-retrieve'."
  (let* ((handle (mm-dissect-buffer t))
         (zoom-level (nth 1 data))
         (address (nth 2 data))
         (previous-buffer (get-buffer address)))
    (url-mark-buffer-as-dead (current-buffer))
    ;; It would be smart to reuse the already created buffer. The only buffer
    ;; that I could not figure out how to delete the MIME content part from it
    ;; before displaying the new image. Since then, we simply delete the
    ;; previous buffer and create a new one.
    (if previous-buffer
        (kill-buffer previous-buffer))

    (with-current-buffer
        (generate-new-buffer address)
      (gmaps-static-mode)

      ;; Save session data
      (setq gmaps-static-current-address address
            gmaps-static-current-zoom-level zoom-level)
      ;; Display media
      (mm-display-part handle)

      (switch-to-buffer (current-buffer))
      (add-hook 'kill-buffer-hook
                `(lambda () (mm-destroy-parts ',handle))
                nil
                t))))

(defun gmaps-static-zoom-in ()
  "Zoom in the map one level."
  (interactive)
  (gmaps-static-show-address gmaps-static-current-address (1+ gmaps-static-current-zoom-level)))

(defun gmaps-static-zoom-out ()
  "Zoom out the map one level."
  (interactive)
  (gmaps-static-show-address gmaps-static-current-address (1- gmaps-static-current-zoom-level)))

(define-derived-mode gmaps-static-mode
  fundamental-mode "Google Maps"
  "Major mode for displaying maps using the Google Maps Static API.
\\{gmaps-static-mode-map}"
  (make-variable-buffer-local 'gmaps-static-current-address)
  (make-variable-buffer-local 'gmaps-static-current-zoom-level))

(provide 'gmaps-static)

;;; gmaps-static.el ends here
