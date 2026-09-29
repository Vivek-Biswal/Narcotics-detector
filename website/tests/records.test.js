import test from 'node:test';
import assert from 'node:assert/strict';
import {sampleRecords,filterRecords,hashImage,csv} from '../src/records.js';
test('search and outcome filters compose without altering source records',()=>{
 assert.equal(filterRecords(sampleRecords,'003')[0].result,'INCONCLUSIVE');
 assert.equal(filterRecords(sampleRecords,'op-1042','NEGATIVE').length,3);
 assert.equal(filterRecords(sampleRecords,'not-found').length,0);
 assert.equal(sampleRecords.length,6);
});
test('SHA-256 matches a published known vector and detects changed bytes',async()=>{
 assert.equal(await hashImage(new Blob(['abc'])),'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
 assert.notEqual(await hashImage(new Blob(['abc'])),await hashImage(new Blob(['abd'])));
});
test('CSV labels sample data and prevents spreadsheet formula injection',()=>{
 assert.match(csv(sampleRecords),/"YES"/);
 assert.match(csv([{test_id:'=1+1',operator_id:'a"b',local:true}]),/"'=1\+1"/);
 assert.match(csv([{test_id:'x',operator_id:'a"b'}]),/"a""b"/);
});
