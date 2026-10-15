import test from 'node:test';
import assert from 'node:assert/strict';
import { createRouteHistory, backAction } from '../src/navigation.js';
import { parseAuthCallback } from '../src/oauth.js';

test('Back retraces pages and never returns an external destination', () => {
  const history = createRouteHistory('overview');
  history.visit('capture'); history.visit('history'); history.visit('login');
  assert.equal(history.back(), 'history');
  assert.equal(history.back(), 'capture');
  assert.equal(history.back(), 'overview');
  assert.equal(history.back(), null);
});

test('duplicate routes do not consume Back and new routes discard forward history', () => {
  const history = createRouteHistory('overview');
  history.visit('capture'); history.visit('capture');
  assert.equal(history.back(), 'overview');
  history.visit('settings'); history.visit('guide');
  assert.equal(history.back(), 'settings');
  history.reset('overview');
  assert.equal(history.back(), null);
});

test('Back dismisses temporary UI before changing the page', () => {
  assert.equal(backAction({ dialogOpen:true, menuOpen:true, cameraOpen:true }), 'dialog');
  assert.equal(backAction({ menuOpen:true, cameraOpen:true }), 'menu');
  assert.equal(backAction({ cameraOpen:true }), 'camera');
  assert.equal(backAction({}), 'page');
});

test('OAuth accepts only the exact app callback with a PKCE code', () => {
  assert.deepEqual(parseAuthCallback('in.etaernal.narctrace://auth/callback?code=test-code'), {code:'test-code'});
  assert.equal(parseAuthCallback('https://evil.example/auth/callback?code=x'), null);
  assert.equal(parseAuthCallback('in.etaernal.narctrace://evil/callback?code=x'), null);
  assert.equal(parseAuthCallback('in.etaernal.narctrace://auth/other?code=x'), null);
  assert.ok(parseAuthCallback('in.etaernal.narctrace://auth/callback#error=access_denied').error);
  assert.ok(parseAuthCallback('in.etaernal.narctrace://auth/callback?error=access_denied').error);
});
