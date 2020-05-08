//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

public enum AWSCognitoAuthError: Error {

    /// User not found in the system.
    case userNotFound

    /// User not confirmed in the system.
    case userNotConfirmed

    /// Username does not exists in the system.
    case usernameExists

    /// Alias already exists in the system.
    case aliasExists

    /// Error in delivering the confirmation code.
    case codeDelivery

    /// Confirmation code entered is not correct.
    case codeMismatch

    /// Confirmation code has expired.
    case codeExpired

    /// One or more parameters are incorrect.
    case invalidParameter

    /// Password given is invalid.
    case invalidPassword

    /// Number of allowed operation have exceeded.
    case limitExceeded

    /// Amazon Cognito cannot find a multi-factor authentication (MFA) method.
    case mfaMethodNotFound

    /// Software token TOTP multi-factor authentication (MFA) is not enabled for the user pool.
    case softwareTokenMFANotEnabled

    /// Required to reset the password of the user.
    case passwordResetRequired

    /// Amazon Cognito service cannot find the requested resource.
    case resourceNotFound

    /// The user has made too many failed attempts for a given action.
    case failedAttemptsLimitExceeded

    /// The user has made too many requests for a given operation.
    case requestLimitExceeded

    /// Amazon Cognito service encounters an invalid AWS Lambda response or encounters an
    /// unexpected exception with the AWS Lambda service.
    case lambda

    /// Device is not tracked.
    case deviceNotTracked

    /// Error in loading the web UI.
    case errorLoadingUI

    /// User cancelled the step
    case userCancelled

    /// Requested operation/value is not available in signed out state.
    case signedOut

    /// Requested resource is not available with the current account setup.
    case invalidAccountTypeException

    /// Request was not completed because of any network related issue
    case network

    /// Session expired need to re-authenticate
    case sessionExpired
}