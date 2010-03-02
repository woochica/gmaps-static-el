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

(defvar gmaps-static-api-url-scheme "http://maps.google.com/maps/api/staticmap?zoom=%s&markers=size:small|color:black|%s|%s&size=500x300&sensor=false"
  "Google Static Maps API URI scheme.")

(defun gmaps-static-show-address (address zoom-level)
  "Show ADDRESS on a map using Google Static Maps API.
Argument ZOOM-LEVEL defaults to `gmaps-static-zoom-level'."
  (interactive
   (list (read-string "Address: ")
         (read-number "Zoom level: " gmaps-static-zoom-level)))
  (let ((address (url-hexify-string address)))
    (url-mm-url (format gmaps-static-api-url-scheme zoom-level address address))))

(provide 'gmaps-static)

;;; gmaps-static.el ends here
