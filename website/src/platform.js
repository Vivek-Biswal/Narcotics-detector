import { Capacitor } from '@capacitor/core';

export const isNative = Capacitor.isNativePlatform();

export async function exportFile(data, name, type) {
  const blob = data instanceof Blob ? data : new Blob([data], { type });
  if (isNative) {
    const [{ Filesystem, Directory }, { Share }] = await Promise.all([
      import('@capacitor/filesystem'), import('@capacitor/share'),
    ]);
    const base64 = await new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => resolve(reader.result.split(',')[1]);
      reader.onerror = () => reject(reader.error);
      reader.readAsDataURL(blob);
    });
    const safeName = name.replace(/[^a-zA-Z0-9._-]/g, '_');
    const { uri } = await Filesystem.writeFile({
      path: `exports/${Date.now()}/${safeName}`, data: base64,
      directory: Directory.Cache, recursive: true,
    });
    await Share.share({ title: 'NarcTrace', files: [uri], dialogTitle: 'Save or share record' });
    return;
  }
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url; link.download = name;
  document.body.append(link); link.click(); link.remove();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}
