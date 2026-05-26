import { Controller } from "@hotwired/stimulus"

/*
 * Popup controller  (data-controller="popup")
 *
 * Bridges Turbo and Bootstrap's modal. Turbo handles *filling* the modal's
 * frame with content; this controller handles *showing/hiding* the Bootstrap
 * modal around it. Attached to the #appModal element in main.html.erb.
 *
 * The flow it orchestrates:
 *   1. An "Edit →" link (data-turbo-frame="drawer") loads a form into the inner
 *      <turbo-frame id="drawer">.
 *   2. That fires turbo:frame-load  → we SHOW the modal.
 *   3. User submits; on success turbo:submit-end fires → we HIDE the modal.
 *      (The edited card is refreshed separately, by update.turbo_stream.erb.)
 *
 * How it reaches the frame: via a Stimulus TARGET, not a querySelector. The
 * frame is tagged `data-popup-target="frame"` in main.html.erb, and we read it
 * here as `this.frameTarget`. That means this file never references the frame's
 * id ("drawer") — so renaming the frame can't break the controller (a lesson
 * learned the hard way when a hardcoded "#modal" selector survived a rename).
 *
 * Note: "popup" (Stimulus controller name) and "drawer" (the turbo-frame id)
 * are matched by two independent systems and just happen to live on the same
 * markup — renaming one does not affect the other.
 */
export default class extends Controller {

    // Declares this.frameTarget, wired to data-popup-target="frame" in the markup.
    static targets = ["frame"]

    connect() {
        // The Bootstrap Modal instance for this element (#appModal).
        this.modal = window.bootstrap.Modal.getOrCreateInstance(this.element)

        // --- OPEN: content just arrived in the frame, so reveal the modal ---
        // turbo:frame-load fires on the inner frame and bubbles up to here.
        // The frame is empty at rest (no src), so this never fires on page load.
        this.element.addEventListener("turbo:frame-load", () => this.modal.show())

        // --- CLOSE: a form submit finished successfully ---
        // On failure (422) detail.success is false, so the modal stays open and
        // shows the re-rendered form with its validation errors.
        this.element.addEventListener("turbo:submit-end", (e) => { if (e.detail.success) this.modal.hide() })

        // --- RESET: once hidden, empty the frame so stale content can't flash ---
        // (and so turbo:frame-load fires fresh the next time it's filled).
        this.element.addEventListener("hidden.bs.modal", () => { this.frameTarget.innerHTML = "" })

        // --- CLEANUP: don't let Turbo cache a page with the modal open ---
        // Otherwise a back/forward visit can restore a stuck backdrop.
        this._beforeCache = () => this.modal.hide()
        document.addEventListener("turbo:before-cache", this._beforeCache)
    }

    disconnect() {
        // The before-cache listener is on `document`, not this.element, so
        // Stimulus won't auto-remove it — do it by hand to avoid leaks.
        document.removeEventListener("turbo:before-cache", this._beforeCache)
    }
}
