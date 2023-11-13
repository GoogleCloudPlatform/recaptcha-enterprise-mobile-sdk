// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package com.google.recaptcha.sample

import androidx.test.espresso.Espresso.onView
import androidx.test.espresso.action.ViewActions.click
import androidx.test.espresso.assertion.ViewAssertions.matches
import androidx.test.espresso.matcher.ViewMatchers.withId
import androidx.test.espresso.matcher.ViewMatchers.withText
import androidx.test.espresso.web.model.Atoms.script
import androidx.test.espresso.web.sugar.Web.onWebView
import androidx.test.espresso.web.webdriver.DriverAtoms.findElement
import androidx.test.espresso.web.webdriver.Locator
import androidx.test.ext.junit.rules.ActivityScenarioRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import org.hamcrest.CoreMatchers.startsWith
import org.junit.Assert.*
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Instrumented test, which will execute on an Android device.
 *
 * See [testing documentation](http://d.android.com/tools/testing).
 */
@RunWith(AndroidJUnit4::class)
class ExampleInstrumentedTest {
  @Test
  fun useAppContext() {
    // Context of the app under test.
    val appContext = InstrumentationRegistry.getInstrumentation().targetContext
    assertEquals("com.google.recaptcha.sample", appContext.packageName)
  }

  @get:Rule val activityRule = ActivityScenarioRule(MainActivity::class.java)

  @Test
  fun loginButtonAppears() {
    onView(withId(R.id.btn_login)).check(matches(withText(startsWith("Login"))))
  }

  @Test
  fun webViewAppears() {
    onView(withId(R.id.btn_login)).perform(click())
    onWebView().withElement(findElement(Locator.ID, "recaptcha-container"))
  }

  // Checks that recaptcha renders a div within the span
  @Test
  fun recaptchaRenders() {
    onView(withId(R.id.btn_login)).perform(click())
    onWebView()
      .withContextualElement(findElement(Locator.ID, "recaptcha-container"))
      .withElement(findElement(Locator.CSS_SELECTOR, "div"))
  }

  @Test
  fun onVerifyCallbackWorks() {
    onView(withId(R.id.btn_login)).perform(click())
    onWebView().perform(script("onVerify(\"FAKETOKEN\");"))
    onView(withId(R.id.response)).check(matches(withText(startsWith("User can Login"))))
  }

  @Test
  fun onErrorCallbackWorks() {
    onView(withId(R.id.btn_login)).perform(click())
    onWebView().perform(script("onError(\"AN ERROR\");"))
    onView(withId(R.id.response)).check(matches(withText(startsWith("Error"))))
  }
}
