package com.example.sample

import android.os.Bundle
import android.view.View
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.fragment.app.commit
import com.google.android.material.textview.MaterialTextView
import com.google.recaptcha.sample.R

class MainActivity : AppCompatActivity(R.layout.activity_main) {

  private val demoRepository = DemoRepository()
  private val loginViewModel: LoginViewModel = LoginViewModel(demoRepository)
  private lateinit var loginFragment:LoginFragment
  private lateinit var homeFragment: HomeFragment
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    enableEdgeToEdge()
    ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
      val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
      v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
      insets
    }

    loginFragment = LoginFragment(loginViewModel)
    homeFragment = HomeFragment(loginViewModel)
    initObservers()
  }

  private fun initObservers() {
    loginViewModel.loginState.observe(this) { logged ->
      supportFragmentManager.commit {
        setReorderingAllowed(true)
        if (logged) {
          replace(R.id.fragment_container_view, HomeFragment(loginViewModel))
        } else {
          add(R.id.fragment_container_view, LoginFragment(loginViewModel))
        }
      }
    }


  }



}