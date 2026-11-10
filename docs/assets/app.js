/* Plico site — theme toggle, scroll reveal, gallery theme switch, lightbox, copy button. No dependencies. */
(function () {
  var root = document.documentElement;

  function store(get, v) {
    try { return get ? localStorage.getItem("plico-theme") : localStorage.setItem("plico-theme", v); }
    catch (e) { return null; }
  }
  function systemDark() { return window.matchMedia && matchMedia("(prefers-color-scheme: dark)").matches; }
  function current() { return root.getAttribute("data-theme") || (systemDark() ? "dark" : "light"); }
  function setTheme(t) {
    root.setAttribute("data-theme", t);
    store(false, t);
    var b = document.getElementById("theme");
    if (b) b.setAttribute("aria-label", t === "dark" ? "Switch to light theme" : "Switch to dark theme");
    syncSeg(t);
  }

  var saved = store(true);
  if (saved === "light" || saved === "dark") root.setAttribute("data-theme", saved);

  var themeBtn = document.getElementById("theme");
  if (themeBtn) {
    themeBtn.addEventListener("click", function () { setTheme(current() === "dark" ? "light" : "dark"); });
    themeBtn.setAttribute("aria-label", current() === "dark" ? "Switch to light theme" : "Switch to dark theme");
  }

  /* gallery segmented control follows the theme */
  var seg = document.querySelectorAll(".seg button");
  function syncSeg(t) {
    seg.forEach(function (b) { b.setAttribute("aria-pressed", String(b.dataset.theme === t)); });
  }
  seg.forEach(function (b) { b.addEventListener("click", function () { setTheme(b.dataset.theme); }); });
  syncSeg(current());

  /* scroll reveal */
  var items = document.querySelectorAll(".rv");
  if ("IntersectionObserver" in window) {
    var io = new IntersectionObserver(function (es) {
      es.forEach(function (e) { if (e.isIntersecting) { e.target.classList.add("in"); io.unobserve(e.target); } });
    }, { threshold: 0.12 });
    items.forEach(function (el) { io.observe(el); });
  } else {
    items.forEach(function (el) { el.classList.add("in"); });
  }

  /* lightbox */
  var dlg = document.getElementById("lightbox");
  if (dlg && dlg.showModal) {
    var lightImgs = dlg.querySelectorAll("img");
    document.querySelectorAll(".shot").forEach(function (fig) {
      fig.addEventListener("click", function () {
        var l = fig.querySelector(".only-light"), d = fig.querySelector(".only-dark");
        lightImgs[0].src = l.currentSrc || l.src; lightImgs[0].alt = l.alt;
        lightImgs[1].src = d.currentSrc || d.src; lightImgs[1].alt = d.alt;
        dlg.showModal();
      });
    });
    dlg.addEventListener("click", function (e) { if (e.target === dlg) dlg.close(); });
    dlg.querySelector("button").addEventListener("click", function () { dlg.close(); });
  }

  /* copy build commands */
  var copy = document.getElementById("copy");
  if (copy) {
    copy.addEventListener("click", function () {
      var text = document.getElementById("build-cmd").innerText;
      var done = function () { copy.textContent = "Copied"; setTimeout(function () { copy.textContent = "Copy"; }, 1800); };
      if (navigator.clipboard) navigator.clipboard.writeText(text).then(done, function () {});
    });
  }
})();
