package in.etaernal.narctrace;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

import androidx.test.core.app.ActivityScenario;
import androidx.test.espresso.Espresso;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(AndroidJUnit4.class)
public class BackNavigationTest {
    private String evaluate(ActivityScenario<MainActivity> scenario, String script) throws Exception {
        AtomicReference<String> result = new AtomicReference<>();
        CountDownLatch done = new CountDownLatch(1);
        scenario.onActivity(activity -> activity.getBridge().getWebView().evaluateJavascript(script, value -> {
            result.set(value); done.countDown();
        }));
        if (!done.await(15, TimeUnit.SECONDS)) throw new AssertionError("WebView did not respond");
        return result.get();
    }

    private void awaitValue(ActivityScenario<MainActivity> scenario, String script, String expected) throws Exception {
        long deadline = System.currentTimeMillis() + 20000;
        String actual;
        do {
            actual = evaluate(scenario, script);
            if (expected.equals(actual)) return;
            Thread.sleep(150);
        } while (System.currentTimeMillis() < deadline);
        assertEquals(expected, actual);
    }

    @Test public void nativeBackReturnsThroughPagesAndKeepsRootOpen() throws Exception {
        try (ActivityScenario<MainActivity> scenario = ActivityScenario.launch(MainActivity.class)) {
            scenario.onActivity(activity -> {
                activity.setShowWhenLocked(true);
                activity.setTurnScreenOn(true);
                activity.getSystemService(android.app.KeyguardManager.class).requestDismissKeyguard(activity, null);
            });
            awaitValue(scenario, "!!document.querySelector('[data-page=history]')", "true");
            // Allow the native listener registration to settle before the first Back.
            evaluate(scenario, "document.querySelector('[data-page=history]').click()");
            awaitValue(scenario, "location.hash", "\"#history\"");
            evaluate(scenario, "document.querySelector('[data-page=guide]').click()");
            awaitValue(scenario, "location.hash", "\"#guide\"");
            evaluate(scenario, "document.querySelector('[data-action=account]').click()");
            awaitValue(scenario, "location.hash", "\"#login\"");
            scenario.onActivity(activity -> activity.getOnBackPressedDispatcher().onBackPressed());
            awaitValue(scenario, "location.hash", "\"#guide\"");
            scenario.onActivity(activity -> activity.getOnBackPressedDispatcher().onBackPressed());
            awaitValue(scenario, "location.hash", "\"#history\"");
            scenario.onActivity(activity -> activity.getOnBackPressedDispatcher().onBackPressed());
            awaitValue(scenario, "location.hash", "\"#overview\"");
            scenario.onActivity(activity -> activity.getOnBackPressedDispatcher().onBackPressed());
            awaitValue(scenario, "document.querySelector('#toast').textContent", "\"You are on the overview page.\"");
            scenario.onActivity(activity -> assertFalse(activity.isFinishing()));
            evaluate(scenario, "document.querySelector('#detail-dialog').showModal()");
            scenario.onActivity(activity -> activity.getOnBackPressedDispatcher().onBackPressed());
            awaitValue(scenario, "document.querySelector('#detail-dialog').open", "false");
            awaitValue(scenario, "location.hash", "\"#overview\"");
        }
    }
}
