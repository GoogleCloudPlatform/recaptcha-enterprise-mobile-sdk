package com.example.sample

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import com.google.android.material.textview.MaterialTextView
import com.google.recaptcha.sample.R

class HomeFragment(private val loginViewModel: LoginViewModel): Fragment(R.layout.home_view) {

  override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
    super.onViewCreated(view, savedInstanceState)

    loginViewModel.loggedUser.value?.let {
      view.findViewById<MaterialTextView>(R.id.txt_home_username).text = it
    }
  }
}