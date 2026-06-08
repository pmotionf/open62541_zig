const std = @import("std");
pub const c = @import("open62541");
const options = @import("options");

pub fn checkStatusCode(code: c.UA_StatusCode) Error!void {
    const code_name = c.UA_StatusCode_name(code);
    if (c.UA_StatusCode_isBad(code)) {
        std.log.err("{s}", .{code_name});
        const ti = @typeInfo(Error).error_set;
        inline for (ti.?) |field| {
            if (std.mem.eql(u8, std.mem.span(code_name), field.name)) {
                return @field(Error, field.name);
            }
        }
        unreachable;
    } else if (c.UA_StatusCode_isUncertain(code)) {
        std.log.warn("{s}", .{code_name});
    }
}

pub fn UA_Clear(p: ?*anyopaque, type_idx: usize) void {
    c.UA_clear(
        p,
        c.UA_DataType_get(type_idx),
    );
}

/// Generated Bad StatusCode from OPC UA as error set
pub const Error = err: {
    @setEvalBranchQuota(2000);
    var T: type = error{};
    const fields = @typeInfo(StatusCode).@"enum".fields;
    for (fields) |field| {
        if (std.mem.startsWith(u8, field.name, "Bad")) {
            T = T || @TypeOf(@field(anyerror, field.name));
        }
    }
    break :err T;
};

pub const StatusCode = enum(u32) {
    Good = 0x00000000,
    InfoTypeDataValue = 0x00000400,
    InfoBitsOverflow = 0x00000080,
    Uncertain = 0x40000000,
    Bad = 0x80000000,
    ///An unexpected error occurred.
    BadUnexpectedError = 0x80010000,
    ///An internal error occurred as a result of a programming or configuration error.
    BadInternalError = 0x80020000,
    ///Not enough memory to complete the operation.
    BadOutOfMemory = 0x80030000,
    ///An operating system resource is not available.
    BadResourceUnavailable = 0x80040000,
    ///A low level communication error occurred.
    BadCommunicationError = 0x80050000,
    ///Encoding halted because of invalid data in the objects being serialized.
    BadEncodingError = 0x80060000,
    ///Decoding halted because of invalid data in the stream.
    BadDecodingError = 0x80070000,
    ///The message encoding/decoding limits imposed by the stack have been exceeded.
    BadEncodingLimitsExceeded = 0x80080000,
    ///The request message size exceeds limits set by the server.
    BadRequestTooLarge = 0x80B80000,
    ///The response message size exceeds limits set by the client.
    BadResponseTooLarge = 0x80B90000,
    ///An unrecognized response was received from the server.
    BadUnknownResponse = 0x80090000,
    ///The operation timed out.
    BadTimeout = 0x800A0000,
    ///The server does not support the requested service.
    BadServiceUnsupported = 0x800B0000,
    ///The operation was cancelled because the application is shutting down.
    BadShutdown = 0x800C0000,
    ///The operation could not complete because the client is not connected to the server.
    BadServerNotConnected = 0x800D0000,
    ///The server has stopped and cannot process any requests.
    BadServerHalted = 0x800E0000,
    ///There was nothing to do because the client passed a list of operations with no elements.
    BadNothingToDo = 0x800F0000,
    ///The request could not be processed because it specified too many operations.
    BadTooManyOperations = 0x80100000,
    ///The request could not be processed because there are too many monitored items in the subscription.
    BadTooManyMonitoredItems = 0x80DB0000,
    ///The extension object cannot be (de)serialized because the data type id is not recognized.
    BadDataTypeIdUnknown = 0x80110000,
    ///The certificate provided as a parameter is not valid.
    BadCertificateInvalid = 0x80120000,
    ///An error occurred verifying security.
    BadSecurityChecksFailed = 0x80130000,
    ///The Certificate has expired or is not yet valid.
    BadCertificateTimeInvalid = 0x80140000,
    ///An Issuer Certificate has expired or is not yet valid.
    BadCertificateIssuerTimeInvalid = 0x80150000,
    ///The HostName used to connect to a Server does not match a HostName in the Certificate.
    BadCertificateHostNameInvalid = 0x80160000,
    ///The URI specified in the ApplicationDescription does not match the URI in the Certificate.
    BadCertificateUriInvalid = 0x80170000,
    ///The Certificate may not be used for the requested operation.
    BadCertificateUseNotAllowed = 0x80180000,
    ///The Issuer Certificate may not be used for the requested operation.
    BadCertificateIssuerUseNotAllowed = 0x80190000,
    ///The Certificate is not trusted.
    BadCertificateUntrusted = 0x801A0000,
    ///It was not possible to determine if the Certificate has been revoked.
    BadCertificateRevocationUnknown = 0x801B0000,
    ///It was not possible to determine if the Issuer Certificate has been revoked.
    BadCertificateIssuerRevocationUnknown = 0x801C0000,
    ///The Certificate has been revoked.
    BadCertificateRevoked = 0x801D0000,
    ///The Issuer Certificate has been revoked.
    BadCertificateIssuerRevoked = 0x801E0000,
    ///User does not have permission to perform the requested operation.
    BadUserAccessDenied = 0x801F0000,
    ///The user identity token is not valid.
    BadIdentityTokenInvalid = 0x80200000,
    ///The user identity token is valid but the server has rejected it.
    BadIdentityTokenRejected = 0x80210000,
    ///The specified secure channel is no longer valid.
    BadSecureChannelIdInvalid = 0x80220000,
    ///The timestamp is outside the range allowed by the server.
    BadInvalidTimestamp = 0x80230000,
    ///The nonce does appear to be not a random value or it is not the correct length.
    BadNonceInvalid = 0x80240000,
    ///The session id is not valid.
    BadSessionIdInvalid = 0x80250000,
    ///The session was closed by the client.
    BadSessionClosed = 0x80260000,
    ///The session cannot be used because ActivateSession has not been called.
    BadSessionNotActivated = 0x80270000,
    ///The subscription id is not valid.
    BadSubscriptionIdInvalid = 0x80280000,
    ///The header for the request is missing or invalid.
    BadRequestHeaderInvalid = 0x802A0000,
    ///The timestamps to return parameter is invalid.
    BadTimestampsToReturnInvalid = 0x802B0000,
    ///The request was cancelled by the client.
    BadRequestCancelledByClient = 0x802C0000,
    ///The subscription was transferred to another session.
    GoodSubscriptionTransferred = 0x002D0000,
    ///The processing will complete asynchronously.
    GoodCompletesAsynchronously = 0x002E0000,
    ///Sampling has slowed down due to resource limitations.
    GoodOverload = 0x002F0000,
    ///The value written was accepted but was clamped.
    GoodClamped = 0x00300000,
    ///Communication with the data source is defined, but not established, and there is no last known value available.
    BadNoCommunication = 0x80310000,
    ///Waiting for the server to obtain values from the underlying data source.
    BadWaitingForInitialData = 0x80320000,
    ///The syntax of the node id is not valid.
    BadNodeIdInvalid = 0x80330000,
    ///The node id refers to a node that does not exist in the server address space.
    BadNodeIdUnknown = 0x80340000,
    ///The attribute is not supported for the specified Node.
    BadAttributeIdInvalid = 0x80350000,
    ///The syntax of the index range parameter is invalid.
    BadIndexRangeInvalid = 0x80360000,
    ///No data exists within the range of indexes specified.
    BadIndexRangeNoData = 0x80370000,
    ///The data encoding is invalid.
    BadDataEncodingInvalid = 0x80380000,
    ///The server does not support the requested data encoding for the node.
    BadDataEncodingUnsupported = 0x80390000,
    ///The access level does not allow reading or subscribing to the Node.
    BadNotReadable = 0x803A0000,
    ///The access level does not allow writing to the Node.
    BadNotWritable = 0x803B0000,
    ///The value was out of range.
    BadOutOfRange = 0x803C0000,
    ///The requested operation is not supported.
    BadNotSupported = 0x803D0000,
    ///A requested item was not found or a search operation ended without success.
    BadNotFound = 0x803E0000,
    ///The object cannot be used because it has been deleted.
    BadObjectDeleted = 0x803F0000,
    ///Requested operation is not implemented.
    BadNotImplemented = 0x80400000,
    ///The monitoring mode is invalid.
    BadMonitoringModeInvalid = 0x80410000,
    ///The monitoring item id does not refer to a valid monitored item.
    BadMonitoredItemIdInvalid = 0x80420000,
    ///The monitored item filter parameter is not valid.
    BadMonitoredItemFilterInvalid = 0x80430000,
    ///The server does not support the requested monitored item filter.
    BadMonitoredItemFilterUnsupported = 0x80440000,
    ///A monitoring filter cannot be used in combination with the attribute specified.
    BadFilterNotAllowed = 0x80450000,
    ///A mandatory structured parameter was missing or null.
    BadStructureMissing = 0x80460000,
    ///The event filter is not valid.
    BadEventFilterInvalid = 0x80470000,
    ///The content filter is not valid.
    BadContentFilterInvalid = 0x80480000,
    ///An unregognized operator was provided in a filter.
    BadFilterOperatorInvalid = 0x80C10000,
    ///A valid operator was provided, but the server does not provide support for this filter operator.
    BadFilterOperatorUnsupported = 0x80C20000,
    ///The number of operands provided for the filter operator was less then expected for the operand provided.
    BadFilterOperandCountMismatch = 0x80C30000,
    ///The operand used in a content filter is not valid.
    BadFilterOperandInvalid = 0x80490000,
    ///The referenced element is not a valid element in the content filter.
    BadFilterElementInvalid = 0x80C40000,
    ///The referenced literal is not a valid value.
    BadFilterLiteralInvalid = 0x80C50000,
    ///The continuation point provide is longer valid.
    BadContinuationPointInvalid = 0x804A0000,
    ///The operation could not be processed because all continuation points have been allocated.
    BadNoContinuationPoints = 0x804B0000,
    ///The operation could not be processed because all continuation points have been allocated.
    BadReferenceTypeIdInvalid = 0x804C0000,
    ///The browse direction is not valid.
    BadBrowseDirectionInvalid = 0x804D0000,
    ///The node is not part of the view.
    BadNodeNotInView = 0x804E0000,
    ///The ServerUri is not a valid URI.
    BadServerUriInvalid = 0x804F0000,
    ///No ServerName was specified.
    BadServerNameMissing = 0x80500000,
    ///No DiscoveryUrl was specified.
    BadDiscoveryUrlMissing = 0x80510000,
    ///The semaphore file specified by the client is not valid.
    BadSempahoreFileMissing = 0x80520000,
    ///The security token request type is not valid.
    BadRequestTypeInvalid = 0x80530000,
    ///The security mode does not meet the requirements set by the Server.
    BadSecurityModeRejected = 0x80540000,
    ///The security policy does not meet the requirements set by the Server.
    BadSecurityPolicyRejected = 0x80550000,
    ///The server has reached its maximum number of sessions.
    BadTooManySessions = 0x80560000,
    ///The user token signature is missing or invalid.
    BadUserSignatureInvalid = 0x80570000,
    ///The signature generated with the client certificate is missing or invalid.
    BadApplicationSignatureInvalid = 0x80580000,
    ///The client did not provide at least one software certificate that is valid and meets the profile requirements for the server.
    BadNoValidCertificates = 0x80590000,
    ///The Server does not support changing the user identity assigned to the session.
    BadIdentityChangeNotSupported = 0x80C60000,
    ///The request was cancelled by the client with the Cancel service.
    BadRequestCancelledByRequest = 0x805A0000,
    ///The parent node id does not to refer to a valid node.
    BadParentNodeIdInvalid = 0x805B0000,
    ///The reference could not be created because it violates constraints imposed by the data model.
    BadReferenceNotAllowed = 0x805C0000,
    ///The requested node id was reject because it was either invalid or server does not allow node ids to be specified by the client.
    BadNodeIdRejected = 0x805D0000,
    ///The requested node id is already used by another node.
    BadNodeIdExists = 0x805E0000,
    ///The node class is not valid.
    BadNodeClassInvalid = 0x805F0000,
    ///The browse name is invalid.
    BadBrowseNameInvalid = 0x80600000,
    ///The browse name is not unique among nodes that share the same relationship with the parent.
    BadBrowseNameDuplicated = 0x80610000,
    ///The node attributes are not valid for the node class.
    BadNodeAttributesInvalid = 0x80620000,
    ///The type definition node id does not reference an appropriate type node.
    BadTypeDefinitionInvalid = 0x80630000,
    ///The source node id does not reference a valid node.
    BadSourceNodeIdInvalid = 0x80640000,
    ///The target node id does not reference a valid node.
    BadTargetNodeIdInvalid = 0x80650000,
    ///The reference type between the nodes is already defined.
    BadDuplicateReferenceNotAllowed = 0x80660000,
    ///The server does not allow this type of self reference on this node.
    BadInvalidSelfReference = 0x80670000,
    ///The reference type is not valid for a reference to a remote server.
    BadReferenceLocalOnly = 0x80680000,
    ///The server will not allow the node to be deleted.
    BadNoDeleteRights = 0x80690000,
    ///The server was not able to delete all target references.
    UncertainReferenceNotDeleted = 0x40BC0000,
    ///The server index is not valid.
    BadServerIndexInvalid = 0x806A0000,
    ///The view id does not refer to a valid view node.
    BadViewIdUnknown = 0x806B0000,
    ///The view timestamp is not available or not supported.
    BadViewTimestampInvalid = 0x80C90000,
    ///The view parameters are not consistent with each other.
    BadViewParameterMismatch = 0x80CA0000,
    ///The view version is not available or not supported.
    BadViewVersionInvalid = 0x80CB0000,
    ///The list of references may not be complete because the underlying system is not available.
    UncertainNotAllNodesAvailable = 0x40C00000,
    ///The server should have followed a reference to a node in a remote server but did not. The result set may be incomplete.
    GoodResultsMayBeIncomplete = 0x00BA0000,
    ///The provided Nodeid was not a type definition nodeid.
    BadNotTypeDefinition = 0x80C80000,
    ///One of the references to follow in the relative path references to a node in the address space in another server.
    UncertainReferenceOutOfServer = 0x406C0000,
    ///The requested operation has too many matches to return.
    BadTooManyMatches = 0x806D0000,
    ///The requested operation requires too many resources in the server.
    BadQueryTooComplex = 0x806E0000,
    ///The requested operation has no match to return.
    BadNoMatch = 0x806F0000,
    ///The max age parameter is invalid.
    BadMaxAgeInvalid = 0x80700000,
    ///The history details parameter is not valid.
    BadHistoryOperationInvalid = 0x80710000,
    ///The server does not support the requested operation.
    BadHistoryOperationUnsupported = 0x80720000,
    ///The defined timestamp to return was invalid.
    BadInvalidTimestampArgument = 0x80BD0000,
    ///The server not does support writing the combination of value, status and timestamps provided.
    BadWriteNotSupported = 0x80730000,
    ///The value supplied for the attribute is not of the same type as the attribute's value.
    BadTypeMismatch = 0x80740000,
    ///The method id does not refer to a method for the specified object.
    BadMethodInvalid = 0x80750000,
    ///The client did not specify all of the input arguments for the method.
    BadArgumentsMissing = 0x80760000,
    ///The server has reached its  maximum number of subscriptions.
    BadTooManySubscriptions = 0x80770000,
    ///The server has reached the maximum number of queued publish requests.
    BadTooManyPublishRequests = 0x80780000,
    ///There is no subscription available for this session.
    BadNoSubscription = 0x80790000,
    ///The sequence number is unknown to the server.
    BadSequenceNumberUnknown = 0x807A0000,
    ///The requested notification message is no longer available.
    BadMessageNotAvailable = 0x807B0000,
    ///The Client of the current Session does not support one or more Profiles that are necessary for the Subscription.
    BadInsufficientClientProfile = 0x807C0000,
    ///The sub-state machine is not currently active.
    BadStateNotActive = 0x80BF0000,
    ///The server cannot process the request because it is too busy.
    BadTcpServerTooBusy = 0x807D0000,
    ///The type of the message specified in the header invalid.
    BadTcpMessageTypeInvalid = 0x807E0000,
    ///The SecureChannelId and/or TokenId are not currently in use.
    BadTcpSecureChannelUnknown = 0x807F0000,
    ///The size of the message specified in the header is too large.
    BadTcpMessageTooLarge = 0x80800000,
    ///There are not enough resources to process the request.
    BadTcpNotEnoughResources = 0x80810000,
    ///An internal error occurred.
    BadTcpInternalError = 0x80820000,
    ///The Server does not recognize the QueryString specified.
    BadTcpEndpointUrlInvalid = 0x80830000,
    ///The request could not be sent because of a network interruption.
    BadRequestInterrupted = 0x80840000,
    ///Timeout occurred while processing the request.
    BadRequestTimeout = 0x80850000,
    ///The secure channel has been closed.
    BadSecureChannelClosed = 0x80860000,
    ///The token has expired or is not recognized.
    BadSecureChannelTokenUnknown = 0x80870000,
    ///The sequence number is not valid.
    BadSequenceNumberInvalid = 0x80880000,
    ///The applications do not have compatible protocol versions.
    BadProtocolVersionUnsupported = 0x80BE0000,
    ///There is a problem with the configuration that affects the usefulness of the value.
    BadConfigurationError = 0x80890000,
    ///The variable should receive its value from another variable, but has never been configured to do so.
    BadNotConnected = 0x808A0000,
    ///There has been a failure in the device/data source that generates the value that has affected the value.
    BadDeviceFailure = 0x808B0000,
    ///There has been a failure in the sensor from which the value is derived by the device/data source.
    BadSensorFailure = 0x808C0000,
    ///The source of the data is not operational.
    BadOutOfService = 0x808D0000,
    ///The deadband filter is not valid.
    BadDeadbandFilterInvalid = 0x808E0000,
    ///Communication to the data source has failed. The variable value is the last value that had a good quality.
    UncertainNoCommunicationLastUsableValue = 0x408F0000,
    ///Whatever was updating this value has stopped doing so.
    UncertainLastUsableValue = 0x40900000,
    ///The value is an operational value that was manually overwritten.
    UncertainSubstituteValue = 0x40910000,
    ///The value is an initial value for a variable that normally receives its value from another variable.
    UncertainInitialValue = 0x40920000,
    ///The value is at one of the sensor limits.
    UncertainSensorNotAccurate = 0x40930000,
    ///The value is outside of the range of values defined for this parameter.
    UncertainEngineeringUnitsExceeded = 0x40940000,
    ///The value is derived from multiple sources and has less than the required number of Good sources.
    UncertainSubNormal = 0x40950000,
    ///The value has been overridden.
    GoodLocalOverride = 0x00960000,
    ///This Condition refresh failed, a Condition refresh operation is already in progress.
    BadRefreshInProgress = 0x80970000,
    ///This condition has already been disabled.
    BadConditionAlreadyDisabled = 0x80980000,
    ///This condition has already been enabled.
    BadConditionAlreadyEnabled = 0x80CC0000,
    ///Property not available, this condition is disabled.
    BadConditionDisabled = 0x80990000,
    ///The specified event id is not recognized.
    BadEventIdUnknown = 0x809A0000,
    ///The event cannot be acknowledged.
    BadEventNotAcknowledgeable = 0x80BB0000,
    ///The dialog condition is not active.
    BadDialogNotActive = 0x80CD0000,
    ///The response is not valid for the dialog.
    BadDialogResponseInvalid = 0x80CE0000,
    ///The condition branch has already been acknowledged.
    BadConditionBranchAlreadyAcked = 0x80CF0000,
    ///The condition branch has already been confirmed.
    BadConditionBranchAlreadyConfirmed = 0x80D00000,
    ///The condition has already been shelved.
    BadConditionAlreadyShelved = 0x80D10000,
    ///The condition is not currently shelved.
    BadConditionNotShelved = 0x80D20000,
    ///The shelving time not within an acceptable range.
    BadShelvingTimeOutOfRange = 0x80D30000,
    ///No data exists for the requested time range or event filter.
    BadNoData = 0x809B0000,
    ///No data found to provide upper or lower bound value.
    BadBoundNotFound = 0x80D70000,
    ///The server cannot retrieve a bound for the variable.
    BadBoundNotSupported = 0x80D80000,
    ///Data is missing due to collection started/stopped/lost.
    BadDataLost = 0x809D0000,
    ///Expected data is unavailable for the requested time range due to an un-mounted volume, an off-line archive or tape, or similar reason for temporary unavailability.
    BadDataUnavailable = 0x809E0000,
    ///The data or event was not successfully inserted because a matching entry exists.
    BadEntryExists = 0x809F0000,
    ///The data or event was not successfully updated because no matching entry exists.
    BadNoEntryExists = 0x80A00000,
    ///The client requested history using a timestamp format the server does not support (i.e requested ServerTimestamp when server only supports SourceTimestamp).
    BadTimestampNotSupported = 0x80A10000,
    ///The data or event was successfully inserted into the historical database.
    GoodEntryInserted = 0x00A20000,
    ///The data or event field was successfully replaced in the historical database.
    GoodEntryReplaced = 0x00A30000,
    ///The value is derived from multiple values and has less than the required number of Good values.
    UncertainDataSubNormal = 0x40A40000,
    ///No data exists for the requested time range or event filter.
    GoodNoData = 0x00A50000,
    ///The data or event field was successfully replaced in the historical database.
    GoodMoreData = 0x00A60000,
    ///The requested number of Aggregates does not match the requested number of NodeIds.
    BadAggregateListMismatch = 0x80D40000,
    ///The requested Aggregate is not support by the server.
    BadAggregateNotSupported = 0x80D50000,
    ///The aggregate value could not be derived due to invalid data inputs.
    BadAggregateInvalidInputs = 0x80D60000,
    ///The aggregate configuration is not valid for specified node.
    BadAggregateConfigurationRejected = 0x80DA0000,
    ///The request pecifies fields which are not valid for the EventType or cannot be saved by the historian.
    GoodDataIgnored = 0x00D90000,
    ///The communication layer has raised an event.
    GoodCommunicationEvent = 0x00A70000,
    ///The system is shutting down.
    GoodShutdownEvent = 0x00A80000,
    ///The operation is not finished and needs to be called again.
    GoodCallAgain = 0x00A90000,
    ///A non-critical timeout occurred.
    GoodNonCriticalTimeout = 0x00AA0000,
    ///One or more arguments are invalid.
    BadInvalidArgument = 0x80AB0000,
    ///Could not establish a network connection to remote server.
    BadConnectionRejected = 0x80AC0000,
    ///The server has disconnected from the client.
    BadDisconnect = 0x80AD0000,
    ///The network connection has been closed.
    BadConnectionClosed = 0x80AE0000,
    ///The operation cannot be completed because the object is closed, uninitialized or in some other invalid state.
    BadInvalidState = 0x80AF0000,
    ///Cannot move beyond end of the stream.
    BadEndOfStream = 0x80B00000,
    ///No data is currently available for reading from a non-blocking stream.
    BadNoDataAvailable = 0x80B10000,
    ///The asynchronous operation is waiting for a response.
    BadWaitingForResponse = 0x80B20000,
    ///The asynchronous operation was abandoned by the caller.
    BadOperationAbandoned = 0x80B30000,
    ///The stream did not return all data requested (possibly because it is a non-blocking stream).
    BadExpectedStreamToBlock = 0x80B40000,
    ///Non blocking behaviour is required and the operation would block.
    BadWouldBlock = 0x80B50000,
    ///A value had an invalid syntax.
    BadSyntaxError = 0x80B60000,
    ///The operation could not be finished because all available connections are in use.
    BadMaxConnectionsReached = 0x80B70000,
};

pub const UA_BrowseResponse = extern struct {
    response_header: ?*const c.UA_ResponseHeader,
    result_size: usize,
    results: [*c]const c.UA_BrowseResult,
    diagnostic_infos_size: usize,
    diagnostic_infos: ?*const c.UA_DiagnosticInfo,

    /// Translate c BrowseResponse native to zig
    pub fn init(bResp: ?*const c.UA_BrowseResponse) UA_BrowseResponse {
        return .{
            .response_header = c.UA_BrowseResponse_getHeader(bResp),
            .result_size = c.UA_BrowseResponse_getResultsSize(bResp),
            .results = c.UA_BrowseResponse_getResults(bResp),
            .diagnostic_infos_size = c.UA_BrowseResponse_getDiagnosticInfosSize(bResp),
            .diagnostic_infos = c.UA_BrowseResponse_getDiagnosticInfos(bResp),
        };
    }
};

pub const UA_ResponseHeader = extern struct {
    timestamp: c.UA_DateTime,
    request_handle: c.UA_UInt32,
    service_result: c.UA_StatusCode,
    service_diagnostics: ?*const c.UA_DiagnosticInfo,
    string_table_size: usize,
    string_table: [*c]const c.UA_String,
    additional_header: ?*const c.UA_ExtensionObject,

    /// Translate c ResponseHeader native to Zig using C readers
    pub fn init(header: ?*const c.UA_ResponseHeader) UA_ResponseHeader {
        return .{
            .timestamp = c.UA_ResponseHeader_getTimestamp(header),
            .request_handle = c.UA_ResponseHeader_getRequestHandle(header),
            .service_result = c.UA_ResponseHeader_getServiceResult(header),
            .service_diagnostics = c.UA_ResponseHeader_getServiceDiagnostics(header),
            .string_table_size = c.UA_ResponseHeader_getStringTableSize(header),
            .string_table = c.UA_ResponseHeader_getStringTable(header),
            .additional_header = c.UA_ResponseHeader_getAdditionalHeader(header),
        };
    }
};

pub const UANodeIdType = enum(c_int) {
    NUMERIC = 0,
    STRING = 3,
    GUID = 4,
    BYTESTRING = 5,
    _,
};

pub const UANodeClass = enum(c_int) {
    UA_NODECLASS_UNSPECIFIED = 0,
    UA_NODECLASS_OBJECT = 1,
    UA_NODECLASS_VARIABLE = 2,
    UA_NODECLASS_METHOD = 4,
    UA_NODECLASS_OBJECTTYPE = 8,
    UA_NODECLASS_VARIABLETYPE = 16,
    UA_NODECLASS_REFERENCETYPE = 32,
    UA_NODECLASS_DATATYPE = 64,
    UA_NODECLASS_VIEW = 128,
    __UA_NODECLASS_FORCE32BIT = 0x7fffffff,
};

pub const UADataTypeKind = enum(std.math.IntFittingRange(
    0,
    c.UA_DATATYPEKINDS - 1,
)) {
    UA_DATATYPEKIND_BOOLEAN = 0,
    UA_DATATYPEKIND_SBYTE = 1,
    UA_DATATYPEKIND_BYTE = 2,
    UA_DATATYPEKIND_INT16 = 3,
    UA_DATATYPEKIND_UINT16 = 4,
    UA_DATATYPEKIND_INT32 = 5,
    UA_DATATYPEKIND_UINT32 = 6,
    UA_DATATYPEKIND_INT64 = 7,
    UA_DATATYPEKIND_UINT64 = 8,
    UA_DATATYPEKIND_FLOAT = 9,
    UA_DATATYPEKIND_DOUBLE = 10,
    UA_DATATYPEKIND_STRING = 11,
    UA_DATATYPEKIND_DATETIME = 12,
    UA_DATATYPEKIND_GUID = 13,
    UA_DATATYPEKIND_BYTESTRING = 14,
    UA_DATATYPEKIND_XMLELEMENT = 15,
    UA_DATATYPEKIND_NODEID = 16,
    UA_DATATYPEKIND_EXPANDEDNODEID = 17,
    UA_DATATYPEKIND_STATUSCODE = 18,
    UA_DATATYPEKIND_QUALIFIEDNAME = 19,
    UA_DATATYPEKIND_LOCALIZEDTEXT = 20,
    UA_DATATYPEKIND_EXTENSIONOBJECT = 21,
    UA_DATATYPEKIND_DATAVALUE = 22,
    UA_DATATYPEKIND_VARIANT = 23,
    UA_DATATYPEKIND_DIAGNOSTICINFO = 24,
    UA_DATATYPEKIND_DECIMAL = 25,
    UA_DATATYPEKIND_ENUM = 26,
    UA_DATATYPEKIND_STRUCTURE = 27,
    UA_DATATYPEKIND_OPTSTRUCT = 28,
    UA_DATATYPEKIND_UNION = 29,
    UA_DATATYPEKIND_BITFIELDCLUSTER = 30,
    _,
};

pub const CustomDataTypes = struct {
    types: []UA_DataType.Extern,

    pub fn init(gpa: std.mem.Allocator, size: usize) !CustomDataTypes {
        return .{ .types = try gpa.alloc(UA_DataType.Extern, size) };
    }

    pub fn deinit(self: CustomDataTypes, gpa: std.mem.Allocator) void {
        gpa.free(self.types);
    }
};

pub const UA_DataType = struct {
    typeName: []const u8,
    typeId: c.UA_NodeId,
    binaryEncodingId: c.UA_NodeId,
    xmlEncodingId: c.UA_NodeId,
    flags: UA_DataType.Flag,
    members: []Member,

    pub const Extern = extern struct {
        typeName: [*]const u8,
        typeId: c.UA_NodeId,
        binaryEncodingId: c.UA_NodeId,
        xmlEncodingId: c.UA_NodeId,
        flags: UA_DataType.Flag,
        members: [*c]Member,

        pub fn init(data_type: UA_DataType) Extern {
            return .{
                .typeName = data_type.typeName.ptr,
                .typeId = data_type.typeId,
                .binaryEncodingId = data_type.binaryEncodingId,
                .xmlEncodingId = data_type.xmlEncodingId,
                .flags = data_type.flags,
                .members = data_type.members.ptr,
            };
        }
    };

    pub const Flag = packed struct(u32) {
        memSize: u16,
        typeKind: u6,
        pointerFree: bool,
        overlayable: bool,
        membersSize: u8,
    };

    pub const Member = extern struct {
        memberName: [*c]const u8,
        memberType: ?*const c.UA_DataType,
        flags: Member.Flag,
        pub const Flag = packed struct(u8) {
            padding: u6,
            isArray: bool,
            isOptional: bool,
        };

        pub fn toOpaque(self: *Member) ?*anyopaque {
            return @ptrCast(@alignCast(self));
        }
    };

    pub const Extended = struct {
        data_type: UA_DataType,
        extern_data_type: UA_DataType.Extern,

        pub fn init(
            gpa: std.mem.Allocator,
            T: type,
            name: [:0]const u8,
            type_id: c.UA_NodeId,
            binary_encoding_id: c.UA_NodeId,
            xml_encoding_id: c.UA_NodeId,
            flags: Flag,
        ) !Extended {
            const data_type: UA_DataType = try .init(
                gpa,
                T,
                name,
                type_id,
                binary_encoding_id,
                xml_encoding_id,
                flags,
            );
            return .{
                .data_type = data_type,
                .extern_data_type = .init(data_type),
            };
        }

        pub fn deinit(self: Extended, gpa: std.mem.Allocator) void {
            self.data_type.deinit(gpa);
        }
    };

    pub fn toExtern(self: *UA_DataType) Extern {
        return .{
            .typeName = self.typeName.ptr,
            .typeId = self.typeId,
            .binaryEncodingId = self.binaryEncodingId,
            .xmlEncodingId = self.xmlEncodingId,
            .flags = self.flags,
            .members = self.members.ptr,
        };
    }

    pub fn init(
        gpa: std.mem.Allocator,
        T: type,
        name: [:0]const u8,
        type_id: c.UA_NodeId,
        binary_encoding_id: c.UA_NodeId,
        xml_encoding_id: c.UA_NodeId,
        flags: UA_DataType.Flag,
    ) !UA_DataType {
        const ti = @typeInfo(T).@"struct";
        var members = try gpa.alloc(UA_DataType.Member, ti.fields.len);
        errdefer gpa.free(members);
        inline for (ti.fields, 0..) |field, i| {
            members[i] = .{
                .memberName = @constCast(field.name),
                .memberType = typeToDataType(field.type),
                .flags = .{
                    .padding = if (i == 0)
                        0
                    else
                        @offsetOf(T, field.name) -
                            @offsetOf(T, ti.fields[i - 1].name) -
                            @sizeOf(ti.fields[i - 1].type),
                    .isArray = if (@typeInfo(field.type) == .@"struct" and
                        @hasField(field.type, "ptr"))
                        true
                    else
                        false,
                    .isOptional = false,
                },
            };
        }
        return .{
            .typeName = try gpa.dupe(u8, name),
            .typeId = type_id,
            .binaryEncodingId = binary_encoding_id,
            .xmlEncodingId = xml_encoding_id,
            .flags = flags,
            .members = members,
        };
    }

    pub fn deinit(self: UA_DataType, gpa: std.mem.Allocator) void {
        gpa.free(self.typeName);
        gpa.free(self.members);
    }
};

fn typeToDataType(T: type) ?*const c.UA_DataType {
    switch (@typeInfo(T)) {
        .array => |array| {
            return typeToDataType(array.child);
        },
        .int => |int| {
            if (int.bits == 8) {
                switch (int.signedness) {
                    .signed => return c.UA_DataType_get(c.UA_SByte),
                    .unsigned => return c.UA_DataType_get(c.UA_Byte),
                }
            } else if (int.bits == 16) {
                switch (int.signedness) {
                    .signed => return c.UA_DataType_get(
                        @intFromEnum(UADataTypeKind.UA_DATATYPEKIND_INT16),
                    ),
                    .unsigned => return c.UA_DataType_get(
                        @intFromEnum(UADataTypeKind.UA_DATATYPEKIND_UINT16),
                    ),
                }
            } else if (int.bits == 32) {
                switch (int.signedness) {
                    .signed => return c.UA_DataType_get(
                        @intFromEnum(UADataTypeKind.UA_DATATYPEKIND_INT32),
                    ),
                    .unsigned => return c.UA_DataType_get(
                        @intFromEnum(UADataTypeKind.UA_DATATYPEKIND_UINT32),
                    ),
                }
            } else if (int.bits == 64) {
                switch (int.signedness) {
                    .signed => return c.UA_DataType_get(
                        @intFromEnum(UADataTypeKind.UA_DATATYPEKIND_INT64),
                    ),
                    .unsigned => return c.UA_DataType_get(
                        @intFromEnum(UADataTypeKind.UA_DATATYPEKIND_UINT64),
                    ),
                }
            } else @compileError(std.fmt.comptimePrint("Unsupported integer type: {}", .{int}));
        },
        .float => |float| {
            if (float.bits == 32)
                return c.UA_DataType_get(
                    @intFromEnum(UADataTypeKind.UA_DATATYPEKIND_FLOAT),
                )
            else if (float.bits == 64)
                return c.UA_DataType_get(
                    @intFromEnum(UADataTypeKind.UA_DATATYPEKIND_DOUBLE),
                )
            else
                @compileError(std.fmt.comptimePrint(
                    "Unsupported floating type: {}",
                    .{float},
                ));
        },
        .@"struct" => |str| {
            inline for (str.fields) |field| {
                if (comptime std.mem.eql(u8, "ptr", field.name)) {
                    return typeToDataType(
                        @typeInfo(field.type).pointer.child,
                    );
                }
            }
            @compileError("Unsupported struct type");
        },
        .bool => return c.UA_DataType_get(
            @intFromEnum(UADataTypeKind.UA_DATATYPEKIND_BOOLEAN),
        ),
        else => |tag| @compileError(
            std.fmt.comptimePrint("Unsupported type: {t}", .{tag}),
        ), // TODO: Support more data type.
    }
}

pub const UA_ConnectionState = enum(c_int) {
    CLOSED,
    OPENING,
    ESTABLISHED,
    CLOSING,
    BLOCKING,
    REOPENING,
    _,
};

pub const UA_SecureChannelState = enum(c_int) {
    CLOSED = 0,
    REVERSE_LISTENING,
    CONNECTING,
    CONNECTED,
    REVERSE_CONNECTED,
    RHE_SENT,
    HEL_SENT,
    HEL_RECEIVED,
    ACK_SENT,
    ACK_RECEIVED,
    OPN_SENT,
    OPEN,
    CLOSING,
    _,
};

pub const UA_SessionState = enum(c_int) {
    CLOSED = 0,
    CREATE_REQUESTED,
    CREATED,
    ACTIVATE_REQUESTED,
    ACTIVATED,
    CLOSING,
    _,
};

pub const NodeId = struct {
    namespace: u16,
    identifier: union(enum) {
        string: []const u8,
        numeric: u32,
        guid: Guid,
        byte: []const u8,
    },

    const Guid = struct {
        data1: u32,
        data2: u16,
        data3: u16,
        data4: [8]u8,

        fn parse(str: []const u8) ParseError!Guid {
            // Validate guid xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
            var iterator = std.mem.tokenizeAny(u8, str, "-");
            const first = iterator.next() orelse
                return error.InvalidNodeId;
            const second = iterator.next() orelse
                return error.InvalidNodeId;
            const third = iterator.next() orelse
                return error.InvalidNodeId;
            const fourth = iterator.next() orelse
                return error.InvalidNodeId;
            const fifth = iterator.next() orelse
                return error.InvalidNodeId;
            if (iterator.next() != null) return error.InvalidNodeId;
            if (first.len != 8 or
                second.len != 4 or
                third.len != 4 or
                fourth.len != 4 or
                fifth.len != 12) return error.InvalidNodeId;
            var res: Guid = undefined;
            res.data1 = try std.fmt.parseInt(u32, first, 16);
            res.data2 = try std.fmt.parseInt(u16, second, 16);
            res.data3 = try std.fmt.parseInt(u16, third, 16);
            for (0..2) |i| {
                res.data4[i] = try std.fmt.parseInt(
                    u8,
                    fourth[i * 2 .. (i + 1) * 2],
                    16,
                );
            }
            for (0..6) |i| {
                res.data4[i + 2] = try std.fmt.parseInt(
                    u8,
                    fifth[i * 2 .. (i + 1) * 2],
                    16,
                );
            }
            return res;
        }

        pub fn format(
            self: @This(),
            writer: *std.Io.Writer,
        ) std.Io.Writer.Error!void {
            // Print the first three numerical blocks with lower-case hex zero-padding
            try writer.print(
                "{x:0>8}-{x:0>4}-{x:0>4}-",
                .{ self.data1, self.data2, self.data3 },
            );

            // Print the first 2 bytes of data4 (the 4th text block)
            try writer.print(
                "{x:0>2}{x:0>2}-",
                .{ self.data4[0], self.data4[1] },
            );

            // Print the remaining 6 bytes of data4 (the 5th text block)
            for (self.data4[2..8]) |b| {
                try writer.print("{x:0>2}", .{b});
            }
        }
    };

    const ParseError = (error{InvalidNodeId} || std.fmt.ParseIntError);

    /// Parse OPC node id from strings. Must be in ns=x;s/b/g/n=y where x
    /// is 2 byte unsigned integer and y depends on the type of node id
    /// identifier.
    pub fn parse(node_id: []const u8) ParseError!NodeId {
        const separator_pos = std.mem.find(u8, node_id, ";") orelse
            return error.InvalidNodeId;
        var res: NodeId = undefined;
        res.namespace = try std.fmt.parseInt(
            u8,
            std.mem.cutPrefix(u8, node_id[0..separator_pos], "ns=") orelse
                return error.InvalidNodeId,
            0,
        );
        const identifier_slice = node_id[separator_pos + 1 ..];
        const identifier, const value = std.mem.cut(
            u8,
            identifier_slice,
            "=",
        ) orelse return error.InvalidNodeId;
        if (std.mem.eql(u8, identifier, "s")) {
            res.identifier = .{ .string = value };
        } else if (std.mem.eql(u8, identifier, "b")) {
            res.identifier = .{ .byte = value };
        } else if (std.mem.eql(u8, identifier, "g")) {
            res.identifier = .{ .guid = try Guid.parse(identifier_slice) };
        } else if (std.mem.eql(u8, identifier, "n")) {
            res.identifier = .{
                .numeric = try std.fmt.parseInt(u32, value, 0),
            };
        } else return error.InvalidNodeId;
        return res;
    }

    /// Same to parse but identifier is allocated for string and byte
    /// identifier. For numeric and guid identifier, use `parse()`. Caller
    /// own memory.
    pub fn parseAlloc(
        gpa: std.mem.Allocator,
        node_id: []const u8,
    ) (std.mem.Allocator.Error || ParseError)!NodeId {
        var res = try parse(node_id);
        switch (res.identifier) {
            .string => |val| {
                res.identifier.string = try gpa.dupe(u8, val);
            },
            .byte => |val| {
                res.identifier.byte = try gpa.dupe(u8, val);
            },
            else => {},
        }
        return res;
    }

    pub fn deinit(self: NodeId, gpa: std.mem.Allocator) void {
        switch (self.identifier) {
            .string, .byte => |val| gpa.free(val),
            else => {},
        }
    }

    pub fn toOpen62541(self: NodeId) c.UA_NodeId {
        return switch (self.identifier) {
            .string => |s| c.UA_NODEID_STRING(self.namespace, @constCast(s.ptr)),
            .numeric => |n| c.UA_NODEID_NUMERIC(self.namespace, n),
            .guid => |g| c.UA_NODEID_GUID(self.namespace, .{
                .data1 = g.data1,
                .data2 = g.data2,
                .data3 = g.data3,
                .data4 = g.data4,
            }),
            .byte => |b| c.UA_NODEID_BYTESTRING(self.namespace, @constCast(b.ptr)),
        };
    }
};
