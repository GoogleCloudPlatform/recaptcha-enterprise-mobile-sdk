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

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import kotlinx.coroutines.suspendCancellableCoroutine

/** Contains utility methods for checking and handling network connectivity. */
object NetworkUtils {
  private const val DEBUG_MODE = true

  /**
   * Checks if the device has an active internet connection.
   *
   * @param context The context.
   * @return True if there's an active internet connection, false otherwise.
   */
  fun isAvailable(context: Context): Boolean {
    if (!hasNetworkStatePermission(context)) {
      logDebug("ACCESS_NETWORK_STATE permission not granted.")
      return true
    }

    return impl.isAvailable(context)
  }

  /**
   * Suspends the coroutine until network availability is restored.
   *
   * @param context The context.
   */
  suspend fun waitForAvailability(context: Context) {
    if (!hasNetworkStatePermission(context)) {
      logDebug("ACCESS_NETWORK_STATE permission not granted. Cannot wait for network availability.")
      return
    }
    impl.waitForAvailability(context)
  }

  private val impl: Impl =
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
      ImplN
    } else {
      ImplPreN
    }

  /**
   * Checks if the ACCESS_NETWORK_STATE permission is granted.
   *
   * @param context The context.
   * @return True if permission is granted, false otherwise.
   */
  private fun hasNetworkStatePermission(context: Context): Boolean {
    val permission = android.Manifest.permission.ACCESS_NETWORK_STATE
    val result = context.packageManager.checkPermission(permission, context.packageName)
    return result == PackageManager.PERMISSION_GRANTED
  }

  private sealed class Impl {
    abstract fun isAvailable(context: Context): Boolean

    abstract suspend fun waitForAvailability(context: Context)
  }

  @RequiresApi(Build.VERSION_CODES.N)
  private object ImplN : Impl() {
    override fun isAvailable(context: Context): Boolean {
      logDebug("Checking network availability")
      val connectivityManager =
        context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

      val activeNetwork = connectivityManager.activeNetwork ?: return false
      val networkCapabilities =
        connectivityManager.getNetworkCapabilities(activeNetwork) ?: return false

      return networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) &&
        networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
    }

    override suspend fun waitForAvailability(context: Context) {
      logDebug("Waiting for network availability")

      suspendCancellableCoroutine { continuation ->
        val connectivityManager =
          context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val networkCallback =
          object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
              logDebug("Network available (Callback method)")
              connectivityManager.unregisterNetworkCallback(this)
              continuation.resume(Unit) {}
            }
          }
        connectivityManager.registerDefaultNetworkCallback(networkCallback)

        // unregister the network callback if the coroutine is cancelled
        continuation.invokeOnCancellation {
          connectivityManager.unregisterNetworkCallback(networkCallback)
        }
      }
    }
  }

  @Suppress("DEPRECATION")
  private object ImplPreN : Impl() {
    override fun isAvailable(context: Context): Boolean {
      logDebug("Checking network availability")
      val connectivityManager =
        context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

      val activeNetworkInfo = connectivityManager.activeNetworkInfo
      return activeNetworkInfo?.isConnected == true
    }

    override suspend fun waitForAvailability(context: Context) {
      logDebug("Waiting for network availability")

      suspendCancellableCoroutine { continuation ->
        val networkReceiver =
          object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
              if (isAvailable(context)) {
                logDebug("Network available")
                context.unregisterReceiver(this)
                continuation.resume(Unit) {}
              }
            }
          }
        context.registerReceiver(
          networkReceiver,
          IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION)
        )

        // unregister the receiver if the coroutine is cancelled
        continuation.invokeOnCancellation { context.unregisterReceiver(networkReceiver) }
      }
    }
  }

  private fun logDebug(message: String) {
    if (DEBUG_MODE) {
      Log.d("NetworkUtils", message)
    }
  }
}