# OTP (One Time Passcode) Screen

## Overview

The OTP page allows a user to enter a OneTimePasscode (OTP) that our backend sends to their account's email address in order to effectively authenticate.

When the user submits the correct secret code, that proves they own the email address associated with the account. Therefore this transaction is enough to "authenticate" the user, or authorize them to make some changes to their account such as changing their password, changing the account email address, or even logging in to the app.

![OTP Screen](../images/otp.png)

## `OtpFragment` and concrete sub-classes

The OTP page is used in a number of different use cases within the application but the page typically looks the same in all these cases. There are slight technical differences in API calls and / or behaviors needed for different use cases.
As a result, in code we have a base abstract [`OtpFragment`](https://github.bamtech.co/Android/Dmgz/blob/development/features/otp/src/main/java/com/bamtechmedia/dominguez/otp/OtpFragment.kt) with several different concrete implementations.

![OtpFragment subclasses](../images/otp_subclasses.png)

### `OtpLoginFragment`

The [`OtpLoginFragment`](https://github.bamtech.co/Android/Dmgz/blob/development/features/otp/src/main/java/com/bamtechmedia/dominguez/otp/OtpLoginFragment.kt) subclass of `OtpFragment` is used in the [OTP Login](../../#otp-login) auth flow.

The use case for this is when there is some security concern about whether the current user actually owns the email address associated with the account they are trying to log in to. In the happy path of the OTP Login flow, upon entering the correct OTP code, the user is authenticated and can access the rest of the app as long as they have an active entitlement.

There is an edge case, called [OTP Login - Forced Password Reset Flow](../../#otp-login-forced-password-reset) where the response for the `authenticateWithOtp` graphql mutation contains `securityAction: ChangePassword`. When this occurs the user will be routed to [Password Reset](password_reset.md) and must reset the account password before becoming authenticated.

### `OtpResetPasswordFragment`

The [`OtpResetPasswordFragment`](https://github.bamtech.co/Android/Dmgz/blob/development/features/otp/src/main/java/com/bamtechmedia/dominguez/otp/OtpResetPasswordFragment.kt) subclass of `OtpFragment` is used in the [Login Forgot Password](../../#login-forgot-password) auth flow.

The use case for this is when the user clicks the ["Forgot Password?" CTA on the Login Password](../login_password/#forgot-password) page. Upon entering the correct OTP code, the user is authenticated, but they are routed to the [`Password Reset`](password_reset.md) page in order to reset their password before entering the rest of the app. If the user quits the app while on the Password Reset page and re-launches, they bypass the actual reset and enter the app as they have already successfully authenticated.

### `OtpRegisterAccountFragment`

The [`OtpRegisterAccountFragment`](https://github.bamtech.co/Android/Dmgz/blob/development/features/otp/src/main/java/com/bamtechmedia/dominguez/otp/OtpRegisterAccountFragment.kt) subclass of `OtpFragment` is used in the [OTP RegisterAccount](../../#otp-registeraccount) signup edge case flow.

The use case for this is when a user attempts to sign up for one app (e.g. **Disney+**) with an email address already associated with an account for one of our other apps (e.g. **Star+**), **AND** that account is in a **Security Flagged** state. In this case the user will be completing a password reset operation (for the shared identity's password) as well as registering a "new" account with this email address for the app which they are attempting to sign up on.

### `OtpVerifyFragment`

The [`OtpVerifyFragment`](https://github.bamtech.co/Android/Dmgz/blob/development/features/otp/src/main/java/com/bamtechmedia/dominguez/otp/OtpVerifyFragment.kt) subclass of `OtpFragment` is used in the [Verify Account Flow](../../../account/#verify-account-flow) from the Account Settings page.

In this flow the OTP operation is used to simply verify that a user actually owns the email address associated with the currently authenticated account.

### `AccountOtpPasscodeFragment`

The [`AccountOtpPasscodeFragment`](https://github.bamtech.co/Android/Dmgz/blob/development/features/otp/src/main/java/com/bamtechmedia/dominguez/otp/AccountOtpPasscodeFragment.kt) subclass of `OtpFragment` is used in the [Change Password Flow](../../../account/#change-password) from the Account Settings page.

In this flow the `actionGrant` returned from a successful [`authenticateWithOtp` mutation](#authenticatewithotp-graphql-mutation) is passed along to the [`AccountPasswordResetFragment`](../password_reset/#accountpasswordresetfragment) to authorize the [`updatePasswordWithActionGrant` mutation](../password_reset/#updatepasswordwithactiongrant-graphql-mutation) called there.

### `OtpChangeEmailFragment`

The [`OtpChangeEmailFragment`](https://github.bamtech.co/Android/Dmgz/blob/development/features/otp/src/main/java/com/bamtechmedia/dominguez/otp/OtpChangeEmailFragment.kt) subclass of `OtpFragment` is used in the [Change Email Flow](../../../account/#change-email).

In this flow, the user is already authenticated. The `actionGrant` token returned after successfully submitting the OTP code is passed to the [Change Email Screen](../../../account/screens/change_email/) to authorize the actual change email operation.

### `OtpConfirmPasswordFragment`

_Details coming soon_

## Resend CTA

The user can click the "Resend" CTA to make another `requestOtp` graphql call which sends the user an email with a randomly generated OTP code.

## `requestOtp` graphql mutation

As soon as any concrete `OtpFragment` is displayed, the app sends the user's current email address to the `requestOtp` graphQl mutation. This operation triggers the backend to construct a new random OTP code and send it to that email address if there is an account on file associated with that email.

The OTP code sent to the user does eventually expire (after 10 or 15 minutes). Once expired, the user will have to use the [Resend CTA](#resend-cta) to trigger a new code to be emailed to them to complete the process.

Any and all error responses from the `requestOtp` mutation are handled the same way. The app uses `ErrorLocalization` to lookup the user-facing error message copy to show the user, and a full-bleed error dialog will be displayed to the user with that error copy.

## `authenticateWithOtp` graphql mutation

When the user submits an OTP code, the app passes that code along with the user's account email address to the orchestration API's `authenticateWithOtp` mutation.

### Successful OTP validation

If the user submits the correct OTP code, the `authenticateWithOtp` mutation response will contain an `actionGrant` token.
An actionGrant token can be used to either log a user in (see [`loginWithActionGrant` graphql mutation](#loginwithactiongrant-graphql-mutation) section below) or to provide authorization to complete some other protected operation in the application such as resetting an account password.

??? info "successful `authenticateWithOtp` example response"

	```json hl_lines="5"
	{
		"data": {
			"authenticateWithOtp": {
				"__typename": "AuthenticateWithOtpResult",
				"actionGrant": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzUxMiJ9.eyJpc3MiOiJ1cm46YmFtdGVjaDpzZXJ2aWNlOmlkcDpkaXNuZXkiLCJzdWIiOiIwZmJjNWY3OC1hNDZmLTQwYWYtYjljNS0zM2M2YjU2ODVlNzMiLCJhdWQiOlsidXJuOmJhbXRlY2g6c2VydmljZTphY2NvdW50OmRpc25leSIsInVybjpiYW10ZWNoOnNlcnZpY2U6aWRwOmRpc25leSJdLCJleHAiOjE2MjkzMDI3NDksIm5iZiI6MTYyOTMwMjQ0OSwiaWF0IjoxNjI5MzAyNDQ5LCJwYXJ0bmVyTmFtZSI6ImRpc25leSIsImFtciI6WyJvdHAiXSwibG9jYWxlIjoiIiwiZW1haWwiOiJkc3NtZXNzYWdpbmcubWF0dC5yQGdtYWlsLmNvbSJ9.RA98WdtoG_CejkM2vMkbiaj_JGTR3uKzsQUbLsTmH0x5vpWgcXxK4lvQhvVlN_50eMo2rBeeyNwxC7lyeIo0aOAOSny8sALlNOpTGJh2mN5FRpxn0NttEzEFzhazJVMijVOIkeLMCmhfoqF8UPtcpjt6dKgxFIuScRGR3aEthNWGxZcpaU5-GKjYb5ks1fP440ril-8TppWeAeBEhvgK1qLnAv_g8vZYh_CC0ai0AEU7XFd51cKq2leKXJns2ZwHn7IDFfR3RsBhaVWqsZ5fpZ-Jfh5WvQURvgZcu3onWrpNRfdCnPieFIPuYTgi7FPF8vmyq84S_iXjUPsnzoJa8Q",
				"securityAction": null,
				"passwordRules": {
					"__typename": "PasswordRules",
					"minLength": 6,
					"charTypes": 2
				}
			}
		},
		"extensions": {
			"sdk": {
				"token": null,
				"session": null,
				"grant": null,
				"accountDelegationRefreshToken": null
			}
		}
	}
	```

The other important part of the response aside from `actionGrant` is the `securityAction` field. If this field comes back with the value `ChangePassword`, the backend is telling us that no matter what operation the user was attempting, we should send them to the [Password Reset](password_reset.md) page next to force the user to reset their password.

??? info "successful `authenticateWithOtp` response with `securityAction: ChangePassword`"

	```json hl_lines="6"
	{
		"data": {
			"authenticateWithOtp": {
				"__typename": "AuthenticateWithOtpResult",
				"actionGrant": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzUxMiJ9.eyJpc3MiOiJ1cm46YmFtdGVjaDpzZXJ2aWNlOmlkcDpkaXNuZXkiLCJzdWIiOiIwZmJjNWY3OC1hNDZmLTQwYWYtYjljNS0zM2M2YjU2ODVlNzMiLCJhdWQiOlsidXJuOmJhbXRlY2g6c2VydmljZTphY2NvdW50OmRpc25leSIsInVybjpiYW10ZWNoOnNlcnZpY2U6aWRwOmRpc25leSJdLCJleHAiOjE2MjkzMDI3NDksIm5iZiI6MTYyOTMwMjQ0OSwiaWF0IjoxNjI5MzAyNDQ5LCJwYXJ0bmVyTmFtZSI6ImRpc25leSIsImFtciI6WyJvdHAiXSwibG9jYWxlIjoiIiwiZW1haWwiOiJkc3NtZXNzYWdpbmcubWF0dC5yQGdtYWlsLmNvbSJ9.RA98WdtoG_CejkM2vMkbiaj_JGTR3uKzsQUbLsTmH0x5vpWgcXxK4lvQhvVlN_50eMo2rBeeyNwxC7lyeIo0aOAOSny8sALlNOpTGJh2mN5FRpxn0NttEzEFzhazJVMijVOIkeLMCmhfoqF8UPtcpjt6dKgxFIuScRGR3aEthNWGxZcpaU5-GKjYb5ks1fP440ril-8TppWeAeBEhvgK1qLnAv_g8vZYh_CC0ai0AEU7XFd51cKq2leKXJns2ZwHn7IDFfR3RsBhaVWqsZ5fpZ-Jfh5WvQURvgZcu3onWrpNRfdCnPieFIPuYTgi7FPF8vmyq84S_iXjUPsnzoJa8Q",
				"securityAction": "ChangePassword",
				"passwordRules": {
					"__typename": "PasswordRules",
					"minLength": 6,
					"charTypes": 2
				}
			}
		},
		"extensions": {
			"sdk": {
				"token": null,
				"session": null,
				"grant": null,
				"accountDelegationRefreshToken": null
			}
		}
	}
	```

### Error handling

#### INVALID_PASSCODE

??? info "`authenticateWithOtp` response - invalid passcode error"

	```json hl_lines="6"
	{
		"data": null,
		"errors": [{
			"message": "upstream: 'identity'\nReceived error response from upstream error with status '400' and description 'Provided passcode is not valid'",
			"extensions": {
				"code": "idp.error.otp.invalid-passcode"
			},
			"path": ["authenticateWithOtp"],
			"locations": [{
				"line": 1,
				"column": 67
			}]
		}],
		"extensions": {
			"sdk": {
				"token": null,
				"session": null,
				"grant": null,
				"accountDelegationRefreshToken": null
			}
		}
	}
	```

If the OTP code the user submitted was incorrect, the `authenticateWithOtp` mutation returns an error response that indicates this. In this case the app displays a form-field error under the OTP input field to let the user know they entered the wrong passcode.

??? example "Incorect OTP code form field error"
	![Incorrect otp code error](../images/otp_incorrect_passcode.png)

#### All other errors

Any other error that is returned in the `authenticateWithOtp` response is handled the same way. The app uses `ErrorLocalization` to lookup the user-facing error message copy to show the user, and a full-bleed error dialog will be displayed to the user with that error copy.

## `loginWithActionGrant` graphql mutation

In some cases, we need to actually "authenticate" the user after successfully submitting the correct OTP code to `authenticateWithOtp`. To do this, we pass the `actionGrant` token that was received from the `authenticateWithOtp` response to the `loginWithActionGrant` graphql mutation. This effectively accomplishes the same thing as the [`login` mutation](../login_password/#login-graphql-mutation).

The cases where the OTP screen also makes this additional call are when the user is not already authenticated (OtpLoginFragment and OtpResetPasswordFragment).
However it is important to note that even on those pages if the `authenticateWithOtp` response contains `securityAction: ChangePassword`, we do not make the `loginWithActionGrant` call at this point, and instead this call will be made after successfully resetting the account's password on the [Password Reset](password_reset.md) page.

## Testing OTP in QA environment

In the QA environment the backend will only send OTP emails to account email addresses that start with `dssmessaging`. In order to receive OTP emails (which is required to test any OTP flow) in the QA environment you need:

1. Access to a real email account that starts with `dssmessaging`. You can just sign up for a free gmail account like `dssmessaging.firstname.lastInitial@gmail.com`.
2. A QA account for the app you are testing that uses that email address.
	- _Note: you can add **+{SomeOtherText}** before `@gmail.com` on the account email address so that you can create multiple QA environment OTP test accounts with one gmail address. For example sign up for a Disney+ account in QA with `dssmessaging.matt.r+skpasswordrules@gmail.com`, and OTP emails will still arrive at the gmail inbox for `dssmessaging.matt.r@gmail.com`._

## Instrumented Tests

- [OtpLoginFlowTest](https://github.bamtech.co/Android/Dmgz/blob/development/mobile/src/androidTestGoogle/java/com/bamtechmedia/dominguez/login/OtpLoginFlowTest.kt)
- [LoginForgotPasswordTest](https://github.bamtech.co/Android/Dmgz/blob/development/mobile/src/androidTestGoogle/java/com/bamtechmedia/dominguez/otp/LoginForgotPasswordTest.kt)
- ChangeEmailTest
	- [mobile](https://github.bamtech.co/Android/Dmgz/blob/development/mobile/src/androidTestGoogle/java/com/bamtechmedia/dominguez/account/email/ChangeEmailTest.kt)
	- [tv](https://github.bamtech.co/Android/Dmgz/blob/development/tv/src/androidTestGoogle/java/com/bamtechmedia/dominguez/account/email/ChangeEmailTest.kt)
- [ChangePasswordFlowTest](https://github.bamtech.co/Android/Dmgz/blob/development/mobile/src/androidTestGoogle/java/com/bamtechmedia/dominguez/account/password/ChangePasswordFlowTest.kt)
- [VerifyAccountFlowTest](https://github.bamtech.co/Android/Dmgz/blob/development/mobile/src/androidTestGoogle/java/com/bamtechmedia/dominguez/account/verify/VerifyAccountFlowTest.kt)
