export const sampleRecords = [
  ['001', 'POSITIVE', '09:42', 'Delhi field unit', 'OP-1042'],
  ['002', 'NEGATIVE', '09:18', 'Delhi field unit', 'OP-1042'],
  ['003', 'INCONCLUSIVE', '08:56', 'North field unit', 'OP-1044'],
  ['004', 'NEGATIVE', '08:34', 'Delhi field unit', 'OP-1042'],
  ['005', 'POSITIVE', '08:12', 'North field unit', 'OP-1044'],
  ['006', 'NEGATIVE', '07:48', 'Delhi field unit', 'OP-1042'],
].map(([id, result, time, unit, operator]) => ({
  id: `sample-${id}`, test_id: `DEMO-2026-${id}`, result,
  captured_at: `2026-09-29T${time}:00+05:30`, unit, operator_id: operator,
  verification_status: 'PENDING', sample: true, classification_method: 'Illustrative sample only',
}));

export function filterRecords(records, query = '', result = 'ALL') {
  const q = query.trim().toLowerCase();
  return records.filter(record => (result === 'ALL' || record.result === result) &&
    [record.test_id, record.operator_id, record.result, record.unit].some(value => String(value ?? '').toLowerCase().includes(q)));
}

export async function hashImage(file) {
  const hash = await crypto.subtle.digest('SHA-256', await file.arrayBuffer());
  return Array.from(new Uint8Array(hash), byte => byte.toString(16).padStart(2, '0')).join('');
}

export function csv(records) {
  const quote = value => `"${String(value ?? '').replace(/^[=+@\-]/, "'$&").replaceAll('"', '""')}"`;
  return [['Test ID', 'Result', 'Timestamp', 'Operator', 'Record status', 'Sample'], ...records.map(r =>
    [r.test_id, r.result ?? 'NOT ANALYSED', r.captured_at, r.operator_id, r.verification_status, r.sample ? 'YES' : 'NO'])]
    .map(row => row.map(quote).join(',')).join('\r\n');
}
