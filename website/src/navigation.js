export function createRouteHistory(initialPage) {
  const entries = [initialPage];
  return {
    visit(page) { if (entries.at(-1) !== page) entries.push(page); },
    back() { if (entries.length < 2) return null; entries.pop(); return entries.at(-1); },
    reset(page) { entries.splice(0, entries.length, page); },
  };
}

export function backAction({ dialogOpen, menuOpen, cameraOpen }) {
  if (dialogOpen) return 'dialog';
  if (menuOpen) return 'menu';
  if (cameraOpen) return 'camera';
  return 'page';
}
