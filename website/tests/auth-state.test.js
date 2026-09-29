import test from 'node:test';
import assert from 'node:assert/strict';
import { authTransition, loginErrorMessage } from '../src/auth-state.js';

test('signed-out focus notifications do not replace an active login form', () => {
  assert.equal(authTransition('SIGNED_OUT', null, null), 'none');
  assert.equal(authTransition('INITIAL_SESSION', null, null), 'none');
  assert.equal(authTransition('SIGNED_OUT', null, { id: 'operator' }), 'signed-out');
});

test('restored sessions enter the workspace and repeated sign-in events do not reload it', () => {
  const session = { user: { id: 'operator' } };
  assert.equal(authTransition('INITIAL_SESSION', session, null), 'signed-in');
  assert.equal(authTransition('SIGNED_IN', session, null), 'signed-in');
  assert.equal(authTransition('SIGNED_IN', session, session.user), 'none');
  assert.equal(authTransition('TOKEN_REFRESHED', session, session.user), 'none');
});

test('login errors explain confirmation and connectivity failures', () => {
  assert.match(loginErrorMessage({ code: 'email_not_confirmed' }), /Confirm your email/);
  assert.match(loginErrorMessage({ code: 'invalid_credentials' }), /email or password is incorrect/);
  assert.match(loginErrorMessage({ message: 'Failed to fetch' }), /internet connection/);
});
