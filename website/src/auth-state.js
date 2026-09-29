// Supabase can report SIGNED_OUT while an already signed-out tab regains focus.
// That notification must not replace a form the user is currently editing.
export function authTransition(event, session, currentUser) {
  if (event === 'SIGNED_OUT') return currentUser ? 'signed-out' : 'none';
  if ((event === 'INITIAL_SESSION' || event === 'SIGNED_IN') && session?.user) {
    return currentUser?.id === session.user.id ? 'none' : 'signed-in';
  }
  return 'none';
}

export function loginErrorMessage(error) {
  if (error?.code === 'email_not_confirmed') return 'Confirm your email address before signing in. Open the confirmation email, then return here and try again.';
  if (error?.code === 'invalid_credentials') return 'The email or password is incorrect. Use the email account registered for NarcTrace.';
  if (/fetch|network/i.test(error?.message || '')) return 'Unable to reach sign-in. Check your internet connection and try again.';
  return error?.message || 'Sign-in could not be completed. Please try again.';
}
