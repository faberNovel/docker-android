package com.fabernovel.test_firebase_test_lab

import androidx.fragment.app.testing.launchFragmentInContainer
import androidx.test.espresso.Espresso.onView
import androidx.test.espresso.assertion.ViewAssertions.matches
import androidx.test.espresso.matcher.ViewMatchers.withId
import androidx.test.espresso.matcher.ViewMatchers.withText
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.fabernovel.test_firebase_test_lab.ui.gallery.GalleryFragment
import com.fabernovel.test_firebase_test_lab.ui.home.HomeFragment
import com.fabernovel.test_firebase_test_lab.ui.slideshow.SlideshowFragment
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class FragmentsTestSuite {
    @Test fun testHomeFragment() {
        launchFragmentInContainer<HomeFragment>()
        onView(withId(R.id.text_home)).check(matches(withText("This is home Fragment")))
    }

    @Test fun testGalleryFragment() {
        launchFragmentInContainer<GalleryFragment>()
        onView(withId(R.id.text_gallery)).check(matches(withText("This is gallery Fragment")))
    }

    @Test fun testSlideshowFragment() {
        launchFragmentInContainer<SlideshowFragment>()
        onView(withId(R.id.text_slideshow)).check(matches(withText("This is slideshow Fragment")))
    }
}
