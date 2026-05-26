// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import { Turbo } from "@hotwired/turbo-rails"
import "controllers"

// Custom Turbo Stream action: a full-page visit triggered from a stream response.
// Lets a form inside a turbo-frame (e.g. the new-pet modal) navigate the WHOLE
// page on success — `<turbo-stream action="redirect" target="/pets/1">` — while
// validation errors still re-render back into the frame on failure.
Turbo.StreamActions.redirect = function () {
  Turbo.visit(this.getAttribute("target"))
}
