const std = @import("std");

const c = @cImport(@cInclude("pthread.h"));

pub const StatusCode = u32;
pub const DateTime = u64;

// Event Filter

pub const EventFilter = extern struct {
    selectClausesSize: usize,
    selectClauses: ?[*]SimpleAttributeOperand,
    whereClause: ContentFilter,
};

pub const EventFieldList = extern struct {
    clientHandle: u32,
    eventFieldsSize: usize,
    eventFields: ?[*]Variant,
};

pub const SimpleAttributeOperand = extern struct {
    typeDefinitionId: NodeId,
    browsePathSize: usize,
    browsePath: ?[*]QualifiedName,
    attributeId: u32,
    indexRange: String,
};

pub const ContentFilter = extern struct {
    elementsSize: usize,
    elements: ?[*]ContentFilterElement,
};

pub const ContentFilterElement = extern struct {
    filterOperator: FilterOperator,
    filterOperandsSize: usize,
    filterOperands: ?[*]ExtensionObject,
};

pub const FilterOperator = enum(c_int) {
    EQUALS = 0,
    ISNULL = 1,
    GREATERTHAN = 2,
    LESSTHAN = 3,
    GREATERTHANOREQUAL = 4,
    LESSTHANOREQUAL = 5,
    LIKE = 6,
    NOT = 7,
    BETWEEN = 8,
    INLIST = 9,
    AND = 10,
    OR = 11,
    CAST = 12,
    INVIEW = 13,
    OFTYPE = 14,
    RELATEDTO = 15,
    BITWISEAND = 16,
    BITWISEOR = 17,
    _,
};

// History Database

pub const RequestHeader = extern struct {
    authenticationToken: NodeId,
    timestamp: DateTime,
    requestHandle: u32,
    returnDiagnostics: u32,
    auditEntryId: String,
    timeoutHint: u32,
    additionalHeader: ExtensionObject,
};

pub const ReadRawModifiedDetails = extern struct {
    isReadModified: bool,
    startTime: DateTime,
    endTime: DateTime,
    numValuesPerNode: u32,
    returnBounds: bool,
};

pub const HistoryReadValueId = extern struct {
    nodeId: NodeId,
    indexRange: String,
    dataEncoding: QualifiedName,
    continuationPoint: ByteString,
};

/// HistoryReadResponse
pub const HistoryReadResponse = extern struct {
    responseHeader: ResponseHeader,
    resultsSize: usize,
    results: ?[*]HistoryReadResult,
    diagnosticInfosSize: usize,
    diagnosticInfos: ?[*]DiagnosticInfo,
};

pub const HistoryReadResult = extern struct {
    statusCode: StatusCode,
    continuationPoint: ByteString,
    historyData: ExtensionObject,
};

pub const HistoryData = extern struct {
    dataValuesSize: usize,
    dataValues: ?[*]DataValue,
};

pub const HistoryModifiedData = extern struct {
    dataValuesSize: usize,
    dataValues: ?[*]DataValue,
    modificationInfosSize: usize,
    modificationInfos: ?[*]ModificationInfo,
};

pub const ModificationInfo = extern struct {
    modificationTime: DateTime,
    updateType: HistoryUpdateType,
    userName: String,
};
pub const HistoryUpdateType = enum(c_int) {
    INSERT = 1,
    REPLACE = 2,
    UPDATE = 3,
    DELETE = 4,
    _,
};

pub const ReadEventDetails = extern struct {
    numValuesPerNode: u32,
    startTime: DateTime,
    endTime: DateTime,
    filter: EventFilter,
};

pub const HistoryEventFieldList = extern struct {
    eventFieldsSize: usize,
    eventFields: ?[*]Variant,
};

pub const AggregateConfiguration = extern struct {
    useServerCapabilitiesDefaults: bool,
    treatUncertainAsBad: bool,
    percentDataBad: u8,
    percentDataGood: u8,
    useSlopedExtrapolation: bool,
};

pub const ReadProcessedDetails = extern struct {
    startTime: DateTime,
    endTime: DateTime,
    processingInterval: f64,
    aggregateTypeSize: usize,
    aggregateType: ?[*]NodeId,
    aggregateConfiguration: AggregateConfiguration,
};

pub const ReadAtTimeDetails = extern struct {
    reqTimesSize: usize,
    reqTimes: ?[*]DateTime,
    useSimpleBounds: bool,
};

pub const UpdateDataDetails = extern struct {
    nodeId: NodeId,
    performInsertReplace: PerformUpdateType,
    updateValuesSize: usize,
    updateValues: ?[*]DataValue,
};

pub const HistoryUpdateResult = extern struct {
    statusCode: StatusCode,
    operationResultsSize: usize,
    operationResults: ?[*]StatusCode,
    diagnosticInfosSize: usize,
    diagnosticInfos: ?[*]DiagnosticInfo,
};

pub const DeleteRawModifiedDetails = extern struct {
    nodeId: NodeId,
    isDeleteModified: bool,
    startTime: DateTime,
    endTime: DateTime,
};

pub const DeleteEventDetails = extern struct {
    nodeId: NodeId,
    eventIdsSize: usize,
    eventIds: ?[*]ByteString,
};

pub const HistoryEvent = extern struct {
    eventsSize: usize,
    events: ?[*]HistoryEventFieldList,
};

pub const HistoryDatabase = extern struct {
    context: ?*anyopaque,

    clear: ?*const fn (hdb: *HistoryDatabase) callconv(.c) void,

    /// Called when a node's value is set.
    setValue: ?*const fn (
        server: *Server,
        hdbContext: ?*anyopaque,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        nodeId: *const NodeId,
        historizing: bool,
        value: *const DataValue,
    ) callconv(.c) void,

    /// Called when an event is triggered.
    setEvent: ?*const fn (
        server: *Server,
        hdbContext: ?*anyopaque,
        originId: *const NodeId,
        emitterId: *const NodeId,
        historicalEventFilter: ?*const EventFilter,
        fieldList: *EventFieldList,
    ) callconv(.c) void,

    /// Called for history read requests (isRawReadModified == false).
    readRaw: ?*const fn (
        server: *Server,
        hdbContext: ?*anyopaque,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        requestHeader: *const RequestHeader,
        historyReadDetails: *const ReadRawModifiedDetails,
        timestampsToReturn: TimestampsToReturn,
        releaseContinuationPoints: bool,
        nodesToReadSize: usize,
        nodesToRead: ?[*]const HistoryReadValueId,
        response: *HistoryReadResponse,
        historyData: ?[*]const ?*HistoryData,
    ) callconv(.c) void,

    /// Read modified history data.
    readModified: ?*const fn (
        server: *Server,
        hdbContext: ?*anyopaque,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        requestHeader: *const RequestHeader,
        historyReadDetails: *const ReadRawModifiedDetails,
        timestampsToReturn: TimestampsToReturn,
        releaseContinuationPoints: bool,
        nodesToReadSize: usize,
        nodesToRead: ?[*]const HistoryReadValueId,
        response: *HistoryReadResponse,
        historyData: ?[*]const ?*HistoryModifiedData,
    ) callconv(.c) void,

    /// Read historical events.
    readEvent: ?*const fn (
        server: *Server,
        hdbContext: ?*anyopaque,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        requestHeader: *const RequestHeader,
        historyReadDetails: *const ReadEventDetails,
        timestampsToReturn: TimestampsToReturn,
        releaseContinuationPoints: bool,
        nodesToReadSize: usize,
        nodesToRead: ?[*]const HistoryReadValueId,
        response: *HistoryReadResponse,
        historyData: ?[*]const ?*HistoryEvent,
    ) callconv(.c) void,

    /// Read processed (aggregated) history data.
    readProcessed: ?*const fn (
        server: *Server,
        hdbContext: ?*anyopaque,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        requestHeader: *const RequestHeader,
        historyReadDetails: *const ReadProcessedDetails,
        timestampsToReturn: TimestampsToReturn,
        releaseContinuationPoints: bool,
        nodesToReadSize: usize,
        nodesToRead: ?[*]const HistoryReadValueId,
        response: *HistoryReadResponse,
        historyData: ?[*]const ?*HistoryData,
    ) callconv(.c) void,

    /// Read history data at specific time stamps.
    readAtTime: ?*const fn (
        server: *Server,
        hdbContext: ?*anyopaque,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        requestHeader: *const RequestHeader,
        historyReadDetails: *const ReadAtTimeDetails,
        timestampsToReturn: TimestampsToReturn,
        releaseContinuationPoints: bool,
        nodesToReadSize: usize,
        nodesToRead: ?[*]const HistoryReadValueId,
        response: *HistoryReadResponse,
        historyData: ?[*]const ?*HistoryData,
    ) callconv(.c) void,

    /// Update historical data.
    updateData: ?*const fn (
        server: *Server,
        hdbContext: ?*anyopaque,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        requestHeader: *const RequestHeader,
        details: *const UpdateDataDetails,
        result: *HistoryUpdateResult,
    ) callconv(.c) void,

    /// Delete raw or modified history data.
    deleteRawModified: ?*const fn (
        server: *Server,
        hdbContext: ?*anyopaque,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        requestHeader: *const RequestHeader,
        details: *const DeleteRawModifiedDetails,
        result: *HistoryUpdateResult,
    ) callconv(.c) void,

    /// Delete historical events.
    deleteEvent: ?*const fn (
        server: *Server,
        hdbContext: ?*anyopaque,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        requestHeader: *const RequestHeader,
        details: *const DeleteEventDetails,
        result: *HistoryUpdateResult,
    ) callconv(.c) void,
};

// Enum

pub const EnumDescription = extern struct {
    dataTypeId: NodeId,
    name: QualifiedName,
    enumDefinition: EnumDefinition,
    builtInType: u8,
};

pub const EnumDefinition = extern struct {
    fieldsSize: usize,
    fields: ?[*]EnumField,
};

pub const EnumField = extern struct {
    value: i64,
    displayName: LocalizedText,
    description: LocalizedText,
    name: String,
};

// PubSub

pub const SimpleTypeDescription = extern struct {
    dataTypeId: NodeId,
    name: QualifiedName,
    baseDataType: NodeId,
    builtInType: u8,
};

pub const DataSetFieldFlags = u16;

pub const FieldMetaData = extern struct {
    name: String,
    description: LocalizedText,
    fieldFlags: DataSetFieldFlags,
    builtInType: u8,
    dataType: NodeId,
    valueRank: i32,
    arrayDimensionsSize: usize,
    arrayDimensions: ?[*]u32,
    maxStringLength: u32,
    dataSetFieldId: Guid,
    propertiesSize: usize,
    properties: ?[*]KeyValuePair,
};

pub const DataSetMetaDataType = extern struct {
    namespacesSize: usize,
    namespaces: ?[*]String,
    structureDataTypesSize: usize,
    structureDataTypes: ?[*]StructureDescription,
    enumDataTypesSize: usize,
    enumDataTypes: ?[*]EnumDescription,
    simpleDataTypesSize: usize,
    simpleDataTypes: ?[*]SimpleTypeDescription,
    name: String,
    description: LocalizedText,
    fieldsSize: usize,
    fields: ?[*]FieldMetaData,
    dataSetClassId: Guid,
    configurationVersion: ConfigurationVersionDataType,
};

pub const ConfigurationVersionDataType = extern struct {
    majorVersion: u32,
    minorVersion: u32,
};

pub const StructureType = enum(c_int) {
    STRUCTURE = 0,
    STRUCTUREWITHOPTIONALFIELDS = 1,
    UNION = 2,
    STRUCTUREWITHSUBTYPEDVALUES = 3,
    UNIONWITHSUBTYPEDVALUES = 4,
    _,
};

pub const StructureField = extern struct {
    name: String,
    description: LocalizedText,
    dataType: NodeId,
    valueRank: i32,
    arrayDimensionsSize: usize,
    arrayDimensions: ?[*]u32,
    maxStringLength: u32,
    isOptional: bool,
};

pub const StructureDefinition = extern struct {
    defaultEncodingId: NodeId,
    baseDataType: NodeId,
    structureType: StructureType,
    fieldsSize: usize,
    fields: ?[*]StructureField,
};

pub const StructureDescription = extern struct {
    dataTypeId: NodeId,
    name: QualifiedName,
    structureDefinition: StructureDefinition,
};

pub const PubSubConfigurationDataType = extern struct {
    publishedDataSetsSize: usize,
    publishedDataSets: ?[*]PublishedDataSetDataType,
    connectionsSize: usize,
    connections: ?[*]PubSubConnectionDataType,
    enabled: bool,
};

pub const PublishedDataSetDataType = extern struct {
    name: String,
    dataSetFolderSize: usize,
    dataSetFolder: ?[*]String,
    dataSetMetaData: DataSetMetaDataType,
    extensionFieldsSize: usize,
    extensionFields: ?[*]KeyValuePair,
    dataSetSource: ExtensionObject,
};

pub const PubSubConnectionDataType = extern struct {
    name: String,
    enabled: bool,
    publisherId: Variant,
    transportProfileUri: String,
    address: ExtensionObject,
    connectionPropertiesSize: usize,
    connectionProperties: ?[*]KeyValuePair,
    transportSettings: ExtensionObject,
    writerGroupsSize: usize,
    writerGroups: ?[*]WriterGroupDataType,
    readerGroupsSize: usize,
    readerGroups: ?[*]ReaderGroupDataType,
};

pub const WriterGroupDataType = extern struct {
    name: String,
    enabled: bool,
    securityMode: MessageSecurityMode,
    securityGroupId: String,
    securityKeyServicesSize: usize,
    securityKeyServices: ?[*]EndpointDescription,
    maxNetworkMessageSize: u32,
    groupPropertiesSize: usize,
    groupProperties: ?[*]KeyValuePair,
    writerGroupId: u16,
    publishingInterval: f64,
    keepAliveTime: f64,
    priority: u8,
    localeIdsSize: usize,
    localeIds: ?[*]String,
    headerLayoutUri: String,
    transportSettings: ExtensionObject,
    messageSettings: ExtensionObject,
    dataSetWritersSize: usize,
    dataSetWriters: ?[*]DataSetWriterDataType,
};

pub const ReaderGroupDataType = extern struct {
    name: String,
    enabled: bool,
    securityMode: MessageSecurityMode,
    securityGroupId: String,
    securityKeyServicesSize: usize,
    securityKeyServices: ?[*]EndpointDescription,
    maxNetworkMessageSize: u32,
    groupPropertiesSize: usize,
    groupProperties: ?[*]KeyValuePair,
    transportSettings: ExtensionObject,
    messageSettings: ExtensionObject,
    dataSetReadersSize: usize,
    dataSetReaders: ?[*]DataSetReaderDataType,
};

pub const DataSetWriterDataType = extern struct {
    name: String,
    enabled: bool,
    dataSetWriterId: u16,
    dataSetFieldContentMask: DataSetFieldContentMask,
    keyFrameCount: u32,
    dataSetName: String,
    dataSetWriterPropertiesSize: usize,
    dataSetWriterProperties: ?[*]KeyValuePair,
    transportSettings: ExtensionObject,
    messageSettings: ExtensionObject,
};

pub const DataSetReaderDataType = extern struct {
    name: String,
    enabled: bool,
    publisherId: Variant,
    writerGroupId: u16,
    dataSetWriterId: u16,
    dataSetMetaData: DataSetMetaDataType,
    dataSetFieldContentMask: DataSetFieldContentMask,
    messageReceiveTimeout: f64,
    keyFrameCount: u32,
    headerLayoutUri: String,
    securityMode: MessageSecurityMode,
    securityGroupId: String,
    securityKeyServicesSize: usize,
    securityKeyServices: ?[*]EndpointDescription,
    dataSetReaderPropertiesSize: usize,
    dataSetReaderProperties: ?[*]KeyValuePair,
    transportSettings: ExtensionObject,
    messageSettings: ExtensionObject,
    subscribedDataSet: ExtensionObject,
};

pub const DataSetFieldContentMask = u32;

// Numeric Range

pub const NumericRangeDimension = extern struct {
    min: u32,
    max: u32,
};

pub const NumericRange = extern struct {
    dimensionsSize: usize,
    dimensions: ?[*]NumericRangeDimension,
};

// Server Node Management

pub const ValueSourceType = enum(c_int) {
    INTERNAL = 0,
    EXTERNAL = 1,
    CALLBACK = 2,
};

pub const ValueSourceNotifications = extern struct {
    /// Notify the application before the value attribute is read.
    onRead: ?*const fn (
        server: *Server,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        nodeid: *const NodeId,
        nodeContext: ?*anyopaque,
        range: ?*const NumericRange,
        value: *const DataValue,
    ) callconv(.c) void,

    /// Notify the application after writing the value attribute.
    onWrite: ?*const fn (
        server: *Server,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        nodeId: *const NodeId,
        nodeContext: ?*anyopaque,
        range: ?*const NumericRange,
        data: *const DataValue,
    ) callconv(.c) void,
};

pub const CallbackValueSource = extern struct {
    /// Copies the data from the source into the provided value.
    /// Supports zero-copy operations.
    read: ?*const fn (
        server: *Server,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        nodeId: *const NodeId,
        nodeContext: ?*anyopaque,
        includeSourceTimeStamp: bool,
        range: ?*const NumericRange,
        value: *DataValue,
    ) callconv(.c) StatusCode,

    /// Write into a data source.
    write: ?*const fn (
        server: *Server,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        nodeId: *const NodeId,
        nodeContext: ?*anyopaque,
        range: ?*const NumericRange,
        value: *const DataValue,
    ) callconv(.c) StatusCode,
};

// Base Node Attribute

pub const REFERENCETYPESET_MAX = 128;

pub const ReferenceTypeSet = extern struct {
    bits: [REFERENCETYPESET_MAX / 32]u32,
};

pub const BrowseDirection = enum(c_int) {
    FORWARD = 0,
    INVERSE = 1,
    BOTH = 2,
    INVALID = 3,
    _, // Handle FORCE32BIT
};

pub const NodestoreVisitor = ?*const fn (visitorCtx: ?*anyopaque, node: *const Node) callconv(.c) void;

pub const NodePointer = extern union {
    /// 00: Small numerical NodeId
    immediate: usize,
    /// 01: Pointer to NodeId
    id: ?*const NodeId,
    /// 10: Pointer to ExternalNodeId
    expandedId: ?*const ExpandedNodeId,
    /// 11: Pointer to a node
    node: ?*const NodeHead,
};

pub const ReferenceTarget = extern struct {
    /// Has to be the first entry
    targetId: NodePointer,
    /// Hash of the target's BrowseName. Set to zero if the target is remote.
    targetNameHash: u32,
};

pub const ReferenceTargetTreeElem = extern struct {
    /// Has to be the first entry
    target: ReferenceTarget,
    /// Hash of the targetId
    targetIdHash: u32,
    idTreeEntry: extern struct {
        left: ?*ReferenceTargetTreeElem,
        right: ?*ReferenceTargetTreeElem,
    },
    nameTreeEntry: extern struct {
        left: ?*ReferenceTargetTreeElem,
        right: ?*ReferenceTargetTreeElem,
    },
};

// Node

pub const LocalizedTextListEntry = extern struct {
    next: ?*LocalizedTextListEntry,
    localizedText: LocalizedText,
};

pub const Node = extern union {
    head: NodeHead,
    variableNode: VariableNode,
    variableTypeNode: VariableTypeNode,
    methodNode: MethodNode,
    objectNode: ObjectNode,
    objectTypeNode: ObjectTypeNode,
    referenceTypeNode: ReferenceTypeNode,
    dataTypeNode: DataTypeNode,
    viewNode: ViewNode,
};

pub const ObjectNode = extern struct {
    head: NodeHead,
    eventNotifier: u8,
};

/// ObjectTypeNode
pub const ObjectTypeNode = extern struct {
    head: NodeHead,
    isAbstract: bool,

    /// Members specific to open62541
    lifecycle: NodeTypeLifecycle,
};

/// ReferenceTypeNode
pub const ReferenceTypeNode = extern struct {
    head: NodeHead,
    isAbstract: bool,
    symmetric: bool,
    inverseName: LocalizedText,

    /// Members specific to open62541
    referenceTypeIndex: u8,
    /// contains the type itself as well
    subTypes: ReferenceTypeSet,
};

/// DataTypeNode
pub const DataTypeNode = extern struct {
    head: NodeHead,
    isAbstract: bool,
};

/// ViewNode
pub const ViewNode = extern struct {
    head: NodeHead,
    eventNotifier: u8,
    containsNoLoops: bool,
};

pub const MethodNode = extern struct {
    head: NodeHead,
    executable: bool,

    /// Members specific to open62541
    method: ?MethodCallback,
};

pub const MethodCallback = *const fn (
    server: *Server,
    sessionId: *const NodeId,
    sessionContext: ?*anyopaque,
    methodId: *const NodeId,
    methodContext: ?*anyopaque,
    objectId: *const NodeId,
    objectContext: ?*anyopaque,
    inputSize: usize,
    input: ?[*]const Variant,
    outputSize: usize,
    output: ?[*]Variant,
) callconv(.c) StatusCode;

pub const NODE_VARIABLEATTRIBUTES = extern struct {
    dataType: NodeId,
    valueRank: i32,
    arrayDimensionsSize: usize,
    arrayDimensions: ?[*]u32,

    valueSourceType: ValueSourceType,
    valueSource: extern union {
        internal: extern struct {
            value: DataValue,
            notifications: ValueSourceNotifications,
        },
        external: extern struct {
            value: ?*?*DataValue, // double-pointer
            notifications: ValueSourceNotifications,
        },
        callback: CallbackValueSource,
    },
};

pub const VariableNode = extern struct {
    head: NodeHead,
    attribute: NODE_VARIABLEATTRIBUTES,

    accessLevel: u8,
    minimumSamplingInterval: f64,
    historizing: bool,

    /// Members specific to open62541
    isDynamic: bool,
};

pub const VariableTypeNode = extern struct {
    head: NodeHead,

    attribute: NODE_VARIABLEATTRIBUTES,

    isAbstract: bool,

    /// Members specific to open62541
    lifecycle: NodeTypeLifecycle,
};

pub const NodeTypeLifecycle = extern struct {
    /// Can be NULL. May replace the nodeContext
    constructor: ?*const fn (
        server: *Server,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        typeNodeId: *const NodeId,
        typeNodeContext: ?*anyopaque,
        nodeId: *const NodeId,
        nodeContext: *?*anyopaque,
    ) callconv(.c) StatusCode,

    /// Can be NULL. May replace the nodeContext.
    destructor: ?*const fn (
        server: *Server,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        typeNodeId: *const NodeId,
        typeNodeContext: ?*anyopaque,
        nodeId: *const NodeId,
        nodeContext: *?*anyopaque,
    ) callconv(.c) void,
};

pub const NodeReferenceKind = extern struct {
    targets: extern union {
        /// Organize the references in an array. Uses less memory, but incurs
        /// lookups in linear time. Recommended if the number of references is
        /// known to be small.
        array: ?[*]ReferenceTarget,

        /// Organize the references in a tree for fast lookup.
        tree: extern struct {
            idRoot: ?*ReferenceTargetTreeElem, // Lookup based on target id
            nameRoot: ?*ReferenceTargetTreeElem, // Lookup based on browseName
        },
    },
    targetsSize: usize,
    /// RefTree or RefArray?
    hasRefTree: bool,
    referenceTypeIndex: u8,
    isInverse: bool,
};

pub const NodeHead = extern struct {
    nodeId: NodeId,
    nodeClass: NodeClass,
    browseName: QualifiedName,

    /// A node can have different localizations for displayName and description.
    displayName: ?*LocalizedTextListEntry,
    description: ?*LocalizedTextListEntry,

    writeMask: u32,
    referencesSize: usize,
    references: ?[*]NodeReferenceKind,

    /// Members specific to open62541
    context: ?*anyopaque,
    /// Constructors were called
    constructed: bool,

    // RBAC and Subscriptions are often enabled in open62541 builds.
    // If you have them disabled, you would comment these out.
    // permissionIndex: u16,
    monitoredItems: ?*MonitoredItem, // MonitoredItem is usually an internal opaque pointer here
};

pub const Nodestore = extern struct {
    /// Nodestore context and lifecycle
    free: ?*const fn (ns: *Nodestore) callconv(.c) void,

    /// Create empty nodes of different node types. Managed by the nodestore.
    newNode: ?*const fn (ns: *Nodestore, nodeClass: NodeClass) callconv(.c) ?*Node,

    deleteNode: ?*const fn (ns: *Nodestore, node: *Node) callconv(.c) void,

    /// Returns a pointer to an immutable node. Call releaseNode when done.
    getNode: ?*const fn (
        ns: *Nodestore,
        nodeId: *const NodeId,
        attributeMask: u32,
        references: ReferenceTypeSet,
        referenceDirections: BrowseDirection,
    ) callconv(.c) ?*const Node,

    /// Similar to getNode but uses a NodePointer structure.
    getNodeFromPtr: ?*const fn (
        ns: *Nodestore,
        ptr: NodePointer,
        attributeMask: u32,
        references: ReferenceTypeSet,
        referenceDirections: BrowseDirection,
    ) callconv(.c) ?*const Node,

    /// Returns a pointer to a mutable version of the node.
    getEditNode: ?*const fn (
        ns: *Nodestore,
        nodeId: *const NodeId,
        attributeMask: u32,
        references: ReferenceTypeSet,
        referenceDirections: BrowseDirection,
    ) callconv(.c) ?*Node,

    /// Similar to getEditNode but uses a NodePointer structure.
    getEditNodeFromPtr: ?*const fn (
        ns: *Nodestore,
        ptr: NodePointer,
        attributeMask: u32,
        references: ReferenceTypeSet,
        referenceDirections: BrowseDirection,
    ) callconv(.c) ?*Node,

    /// Release a node retrieved with getNode or getNodeFromPtr.
    releaseNode: ?*const fn (ns: *Nodestore, node: *const Node) callconv(.c) void,

    /// Returns an editable copy of a node.
    getNodeCopy: ?*const fn (
        ns: *Nodestore,
        nodeId: *const NodeId,
        outNode: **Node,
    ) callconv(.c) StatusCode,

    /// Inserts a new node into the nodestore.
    insertNode: ?*const fn (
        ns: *Nodestore,
        node: *Node,
        addedNodeId: ?*NodeId,
    ) callconv(.c) StatusCode,

    /// Replace a node in the nodestore.
    replaceNode: ?*const fn (ns: *Nodestore, node: *Node) callconv(.c) StatusCode,

    /// Removes a node from the nodestore.
    removeNode: ?*const fn (ns: *Nodestore, nodeId: *const NodeId) callconv(.c) StatusCode,

    /// Maps ReferenceTypeIndex to NodeId.
    getReferenceTypeId: ?*const fn (
        ns: *Nodestore,
        refTypeIndex: u8,
    ) callconv(.c) ?*const NodeId,

    /// Execute a callback for every node in the nodestore.
    iterate: ?*const fn (
        ns: *Nodestore,
        visitor: NodestoreVisitor,
        visitorCtx: ?*anyopaque,
    ) callconv(.c) void,
};

// Access Control

pub const AccessControl = extern struct {
    context: ?*anyopaque,
    clear: ?*const fn (ac: *AccessControl) callconv(.c) void,

    /// Supported login mechanisms. The server endpoints are created from here.
    userTokenPoliciesSize: usize,
    userTokenPolicies: ?[*]UserTokenPolicy,

    /// Authenticate a session.
    activateSession: ?*const fn (
        server: *Server,
        ac: *AccessControl,
        endpointDescription: *const EndpointDescription,
        secureChannelRemoteCertificate: *const ByteString,
        sessionId: *const NodeId,
        userIdentityToken: *const ExtensionObject,
        sessionContext: *?*anyopaque,
    ) callconv(.c) StatusCode,

    /// Deauthenticate a session and cleanup
    closeSession: ?*const fn (
        server: *Server,
        ac: *AccessControl,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
    ) callconv(.c) void,

    /// Access control for all nodes
    getUserRightsMask: ?*const fn (
        server: *Server,
        ac: *AccessControl,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        nodeId: *const NodeId,
        nodeContext: ?*anyopaque,
    ) callconv(.c) u32,

    /// Additional access control for variable nodes
    getUserAccessLevel: ?*const fn (
        server: *Server,
        ac: *AccessControl,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        nodeId: *const NodeId,
        nodeContext: ?*anyopaque,
    ) callconv(.c) u8,

    /// Additional access control for method nodes
    getUserExecutable: ?*const fn (
        server: *Server,
        ac: *AccessControl,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        methodId: *const NodeId,
        methodContext: ?*anyopaque,
    ) callconv(.c) bool,

    /// Additional access control for calling a method node in the context of a specific object
    getUserExecutableOnObject: ?*const fn (
        server: *Server,
        ac: *AccessControl,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        methodId: *const NodeId,
        methodContext: ?*anyopaque,
        objectId: *const NodeId,
        objectContext: ?*anyopaque,
    ) callconv(.c) bool,

    /// Allow adding a node
    allowAddNode: ?*const fn (
        server: *Server,
        ac: *AccessControl,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        item: *const AddNodesItem,
    ) callconv(.c) bool,

    /// Allow adding a reference
    allowAddReference: ?*const fn (
        server: *Server,
        ac: *AccessControl,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        item: *const AddReferencesItem,
    ) callconv(.c) bool,

    /// Allow deleting a node
    allowDeleteNode: ?*const fn (
        server: *Server,
        ac: *AccessControl,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        item: *const DeleteNodesItem,
    ) callconv(.c) bool,

    /// Allow deleting a reference
    allowDeleteReference: ?*const fn (
        server: *Server,
        ac: *AccessControl,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        item: *const DeleteReferencesItem,
    ) callconv(.c) bool,

    /// Allow browsing a node
    allowBrowseNode: ?*const fn (
        server: *Server,
        ac: *AccessControl,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        nodeId: *const NodeId,
        nodeContext: ?*anyopaque,
    ) callconv(.c) bool,

    // Subscription callbacks (wrapped in optionality or handled by build tags in Zig)
    allowCreateSubscription: ?*const fn (
        server: *Server,
        ac: *AccessControl,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
    ) callconv(.c) bool,

    allowTransferSubscription: ?*const fn (
        server: *Server,
        ac: *AccessControl,
        oldSessionId: *const NodeId,
        oldSessionContext: ?*anyopaque,
        newSessionId: *const NodeId,
        newSessionContext: ?*anyopaque,
    ) callconv(.c) bool,

    // Historizing callbacks
    allowHistoryUpdateUpdateData: ?*const fn (
        server: *Server,
        ac: *AccessControl,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        nodeId: *const NodeId,
        performInsertReplace: PerformUpdateType,
        value: *const DataValue,
    ) callconv(.c) bool,

    allowHistoryUpdateDeleteRawModified: ?*const fn (
        server: *Server,
        ac: *AccessControl,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        nodeId: *const NodeId,
        startTimestamp: i64,
        endTimestamp: i64,
        isDeleteModified: bool,
    ) callconv(.c) bool,
};

pub const AddNodesItem = extern struct {
    parentNodeId: ExpandedNodeId,
    referenceTypeId: NodeId,
    requestedNewNodeId: ExpandedNodeId,
    browseName: QualifiedName,
    nodeClass: NodeClass,
    nodeAttributes: ExtensionObject,
    typeDefinition: ExpandedNodeId,
};

pub const AddReferencesItem = extern struct {
    sourceNodeId: NodeId,
    referenceTypeId: NodeId,
    isForward: bool,
    targetServerUri: String,
    targetNodeId: ExpandedNodeId,
    targetNodeClass: NodeClass,
};

pub const DeleteNodesItem = extern struct {
    nodeId: NodeId,
    deleteTargetReferences: bool,
};

pub const DeleteReferencesItem = extern struct {
    sourceNodeId: NodeId,
    referenceTypeId: NodeId,
    isForward: bool,
    targetNodeId: ExpandedNodeId,
    deleteBidirectional: bool,
};

pub const PerformUpdateType = enum(c_int) {
    INSERT = 1,
    REPLACE = 2,
    UPDATE = 3,
    REMOVE = 4,
    _, // Handle FORCE32BIT or other values
};

pub const ExpandedNodeId = extern struct {
    nodeId: NodeId,
    namespaceUri: String,
    serverIndex: u32,
};

pub const NodeClass = enum(c_int) {
    UNSPECIFIED = 0,
    OBJECT = 1,
    VARIABLE = 2,
    METHOD = 4,
    OBJECTTYPE = 8,
    VARIABLETYPE = 16,
    REFERENCETYPE = 32,
    DATATYPE = 64,
    VIEW = 128,
    _, // Handle FORCE32BIT
};

// GDS Manager

pub const TrustListDataType = extern struct {
    specifiedLists: u32,
    trustedCertificatesSize: usize,
    trustedCertificates: ?[*]ByteString,
    trustedCrlsSize: usize,
    trustedCrls: ?[*]ByteString,
    issuerCertificatesSize: usize,
    issuerCertificates: ?[*]ByteString,
    issuerCrlsSize: usize,
    issuerCrls: ?[*]ByteString,
};

pub const GDSTransactionState = enum(c_int) {
    FRESH = 0,
    PENDING = 1,
};

pub const GDSCertificateInfo = extern struct {
    certificate: ByteString,
    privateKey: ByteString,
    certificateGroup: NodeId,
    certificateType: NodeId,
};

pub const GDSTransaction = extern struct {
    server: ?*Server,
    sessionId: NodeId,
    state: GDSTransactionState,

    localCsrCertificate: ByteString,

    certGroupSize: usize,
    certGroups: ?[*]CertificateGroup,

    certificateInfosSize: usize,
    certificateInfos: ?[*]GDSCertificateInfo,

    /// Callback to close all SecureChannels after calling applyChanges
    /// and freeing the transaction.
    dc: DelayedCallback,
};

pub const GDSManager = extern struct {
    /// Transaction for certificate management
    transaction: GDSTransaction,
    /// Contains context information necessary for reading and writing the TrustList as a file type
    fileInfoContext: ?*anyopaque,
    /// Holds the ID for the repeated callback that verifies the presence of sessions
    /// with an active transaction or an open trust list
    checkSessionCallbackId: u64,
};

pub const CertificateGroup = extern struct {
    /// The NodeId of the certificate group this pki store is associated with
    certificateGroupId: NodeId,

    /// Context-pointer to be set by the CertificateGroup plugin implementation
    context: ?*anyopaque,

    /// Pointer to logging pointer in the server/client configuration.
    logging: ?*const Logger,

    getTrustList: ?*const fn (certGroup: *CertificateGroup, trustList: *TrustListDataType) callconv(.c) StatusCode,

    setTrustList: ?*const fn (certGroup: *CertificateGroup, trustList: *const TrustListDataType) callconv(.c) StatusCode,

    addToTrustList: ?*const fn (certGroup: *CertificateGroup, trustList: *const TrustListDataType) callconv(.c) StatusCode,

    removeFromTrustList: ?*const fn (certGroup: *CertificateGroup, trustList: *const TrustListDataType) callconv(.c) StatusCode,

    getRejectedList: ?*const fn (certGroup: *CertificateGroup, rejectedList: *?[*]ByteString, rejectedListSize: *usize) callconv(.c) StatusCode,

    /// Provides all associated CRLs for a CA certificate.
    getCertificateCrls: ?*const fn (certGroup: *CertificateGroup, certificate: *const ByteString, isTrusted: bool, crls: *?[*]ByteString, crlsSize: *usize) callconv(.c) StatusCode,

    verifyCertificate: ?*const fn (certGroup: *CertificateGroup, certificate: *const ByteString) callconv(.c) StatusCode,

    clear: ?*const fn (certGroup: *CertificateGroup) callconv(.c) void,
};

// Extension Object

pub const ExtensionObjectEncoding = enum(c_int) {
    ENCODED_NOBODY = 0,
    ENCODED_BYTESTRING = 1,
    ENCODED_XML = 2,
    DECODED = 3,
    /// Don't delete the content together with the ExtensionObject
    DECODED_NODELETE = 4,
};

pub const ExtensionObject = extern struct {
    encoding: ExtensionObjectEncoding,
    content: extern union {
        encoded: extern struct {
            /// The nodeid of the datatype
            typeId: NodeId,
            /// The bytestring of the encoded data
            body: ByteString,
        },
        decoded: extern struct {
            type: ?*const DataType,
            data: ?*anyopaque,
        },
    },
};

pub const ByteString = String;

// Read value ID

pub const ReadValueId = extern struct {
    nodeId: NodeId,
    attributeId: u32,
    indexRange: String,
    dataEncoding: QualifiedName,
};

// Application Type

pub const ApplicationType = enum(c_int) {
    SERVER = 0,
    CLIENT = 1,
    CLIENTANDSERVER = 2,
    DISCOVERYSERVER = 3,
    /// Force the enum to be 32-bit (corresponds to 0x7fffffff in C)
    _,
};

// Localized Text

pub const LocalizedText = extern struct {
    locale: String,
    text: String,
};

// ApplicationDescription

pub const ApplicationDescription = extern struct {
    applicationUri: String,
    productUri: String,
    applicationName: LocalizedText,
    applicationType: ApplicationType,
    gatewayServerUri: String,
    discoveryProfileUri: String,
    discoveryUrlsSize: usize,
    discoveryUrls: ?[*]String,
};

// Event Sources

pub const EventSourceState = enum(c_int) {
    FRESH = 0,
    /// Registered but stopped
    STOPPED = 1,
    STARTING = 2,
    STARTED = 3,
    /// Stopping in progress, needs EventLoop cycles to finish
    STOPPING = 4,
};

pub const EventSourceType = enum(c_int) {
    CONNECTIONMANAGER = 0,
    INTERRUPTMANAGER = 1,
};

pub const EventSource = extern struct {
    /// Singly-linked list for use by the application that registered the ES
    next: ?*EventSource,

    eventSourceType: EventSourceType,

    // Configuration
    /// Unique name of the ES
    name: String,
    /// EventLoop where the ES is registered
    eventLoop: ?*EventLoop,
    params: KeyValueMap,

    // Lifecycle
    state: EventSourceState,

    start: ?*const fn (es: ?*EventSource) callconv(.c) StatusCode,
    /// Asynchronous. Iterate the EventLoop until the EventSource is stopped.
    stop: ?*const fn (es: ?*EventSource) callconv(.c) void,
    free: ?*const fn (es: ?*EventSource) callconv(.c) StatusCode,
};

// Timer Policy

pub const TimerPolicy = enum(c_int) {
    /// Execute the timer once and remove
    ONCE = 0,
    /// Repeated timer. Upon cycle miss, execute "now" and wait exactly
    /// for the interval until the next execution (new basetime).
    CURRENTTIME = 1,
    /// Repeated timer. Upon cycle miss, execute "now" and fall back
    /// into the regular cycle from the original basetime.
    BASETIME = 2,
};

// Node ID

pub const NodeIdType = enum(c_int) {
    NUMERIC = 0,
    STRING = 3,
    GUID = 4,
    BYTESTRING = 5,
};

pub const NodeId = extern struct {
    namespaceIndex: u16,
    identifierType: NodeIdType,
    identifier: extern union {
        numeric: u32,
        string: String,
        guid: Guid,
        byteString: String,
    },
};

pub const Guid = extern struct {
    data1: u32,
    data2: u16,
    data3: u16,
    data4: [8]u8,
};

// Data Type

pub const DataTypeMember = extern struct {
    memberName: [*:0]const u8,
    memberType: ?*const DataType,
    /// Bitfields: 6 bits padding, 1 bit isArray, 1 bit isOptional
    flags: packed struct(u8) {
        padding: u6,
        isArray: bool,
        isOptional: bool,
    },
};

pub const DATATYPEKINDS: usize = 31;

pub const DataTypeKind = enum(u6) {
    BOOLEAN = 0,
    SBYTE = 1,
    BYTE = 2,
    INT16 = 3,
    UINT16 = 4,
    INT32 = 5,
    UINT32 = 6,
    INT64 = 7,
    UINT64 = 8,
    FLOAT = 9,
    DOUBLE = 10,
    STRING = 11,
    DATETIME = 12,
    GUID = 13,
    BYTESTRING = 14,
    XMLELEMENT = 15,
    NODEID = 16,
    EXPANDEDNODEID = 17,
    STATUSCODE = 18,
    QUALIFIEDNAME = 19,
    LOCALIZEDTEXT = 20,
    EXTENSIONOBJECT = 21,
    DATAVALUE = 22,
    VARIANT = 23,
    DIAGNOSTICINFO = 24,
    DECIMAL = 25,
    ENUM = 26,
    STRUCTURE = 27,
    OPTSTRUCT = 28,
    UNION = 29,
    BITFIELDCLUSTER = 30,
};

pub const DataType = extern struct {
    typeName: [*:0]const u8,
    typeId: NodeId,
    binaryEncodingId: NodeId,
    xmlEncodingId: NodeId,

    /// Bitfields mapping to the 32-bit layout in C
    layout: packed struct(u32) {
        memSize: u16,
        typeKind: DataTypeKind,
        pointerFree: bool,
        overlayable: bool,
        membersSize: u8,
    },

    members: ?[*]DataTypeMember,
};

// Variant

pub const VariantStorageType = enum(c_int) {
    /// The data has the same lifecycle as the variant
    DATA = 0,
    /// The data is "borrowed" by the variant and is not deleted when the
    /// variant is cleared up. The array dimensions are also borrowed.
    DATA_NODELETE = 1,
};

pub const Variant = extern struct {
    /// The data type description
    type: ?*const DataType,
    /// Whether the data is owned or borrowed
    storageType: VariantStorageType,
    /// The number of elements in the data array
    arrayLength: usize,
    /// Points to the scalar or array data
    data: ?*anyopaque,
    /// The number of dimensions
    arrayDimensionsSize: usize,
    /// The length of each dimension
    arrayDimensions: ?[*]u32,
};

// Key Value Map

pub const KeyValuePair = extern struct {
    key: QualifiedName,
    value: Variant,
};

pub const QualifiedName = extern struct {
    namespaceIndex: u16,
    name: String,
};

pub const String = extern struct {
    /// The length of the string
    length: usize,
    /// The content (not null-terminated)
    data: ?[*]u8,
};

pub const KeyValueMap = extern struct {
    mapSize: usize,
    map: ?[*]KeyValuePair,
};

pub extern const UA_KEYVALUEMAP_NULL: KeyValueMap;

pub extern fn UA_KeyValueMap_new() callconv(.c) ?*KeyValueMap;

pub extern fn UA_KeyValueMap_clear(map: ?*KeyValueMap) callconv(.c) void;

pub extern fn UA_KeyValueMap_delete(map: ?*KeyValueMap) callconv(.c) void;

pub extern fn UA_KeyValueMap_isEmpty(map: ?*const KeyValueMap) callconv(.c) bool;

pub extern fn UA_KeyValueMap_contains(map: ?*const KeyValueMap, key: QualifiedName) callconv(.c) bool;

pub extern fn UA_KeyValueMap_set(
    map: ?*KeyValueMap,
    key: QualifiedName,
    value: ?*const Variant,
) callconv(.c) StatusCode;

pub extern fn UA_KeyValueMap_setShallow(
    map: ?*KeyValueMap,
    key: QualifiedName,
    value: ?*Variant,
) callconv(.c) StatusCode;

pub extern fn UA_KeyValueMap_setScalar(
    map: ?*KeyValueMap,
    key: QualifiedName,
    p: ?*const anyopaque,
    @"type": ?*const DataType,
) callconv(.c) StatusCode;

pub extern fn UA_KeyValueMap_setScalarShallow(
    map: ?*KeyValueMap,
    key: QualifiedName,
    p: ?*anyopaque,
    @"type": ?*const DataType,
) callconv(.c) StatusCode;

pub extern fn UA_KeyValueMap_get(
    map: ?*const KeyValueMap,
    key: QualifiedName,
) callconv(.c) ?*const Variant;

pub extern fn UA_KeyValueMap_getScalar(
    map: ?*const KeyValueMap,
    key: QualifiedName,
    @"type": ?*const DataType,
) callconv(.c) ?*const anyopaque;

pub extern fn UA_KeyValueMap_remove(
    map: ?*KeyValueMap,
    key: QualifiedName,
) callconv(.c) StatusCode;

pub extern fn UA_KeyValueMap_copy(
    src: ?*const KeyValueMap,
    dst: ?*KeyValueMap,
) callconv(.c) StatusCode;

pub extern fn UA_KeyValueMap_merge(
    lhs: ?*KeyValueMap,
    rhs: ?*const KeyValueMap,
) callconv(.c) StatusCode;

// Logging

pub const LogLevel = enum(c_int) {
    TRACE = 100,
    DEBUG = 200,
    INFO = 300,
    WARNING = 400,
    ERROR = 500,
    FATAL = 600,
};

pub const LOGCATEGORIES: usize = 10;

pub const LogCategory = enum(c_int) {
    NETWORK = 0,
    SECURECHANNEL = 1,
    SESSION = 2,
    SERVER = 3,
    CLIENT = 4,
    APPLICATION = 5,
    // USERLAND = 5, (Duplicate in C)
    SECURITY = 6,
    // SECURITYPOLICY = 6, (Duplicate in C)
    EVENTLOOP = 7,
    PUBSUB = 8,
    DISCOVERY = 9,

    pub const USERLAND = LogCategory.APPLICATION;
    pub const SECURITYPOLICY = LogCategory.SECURITY;
};

pub const Logger = extern struct {
    /// Log a message.
    /// Note: va_list mapping in Zig requires @import("std").builtin.VaList
    log: ?*const fn (
        logContext: ?*anyopaque,
        level: LogLevel,
        category: LogCategory,
        msg: [*:0]const u8,
        args: std.builtin.VaList,
    ) callconv(.c) void,

    context: ?*anyopaque,

    clear: ?*const fn (logger: ?*Logger) callconv(.c) void,
};

// Event Loop

pub const Callback = ?*const fn (application: ?*anyopaque, context: ?*anyopaque) callconv(.c) void;

pub const DelayedCallback = extern struct {
    next: ?*DelayedCallback,
    callback: Callback,
    application: ?*anyopaque,
    context: ?*anyopaque,
};

pub const EventLoopState = enum(c_int) {
    FRESH = 0,
    STOPPED = 1,
    STARTED = 2,
    STOPPING = 3,
};

pub const EventLoop = extern struct {
    // Configuration
    logger: ?*const Logger,
    params: KeyValueMap,

    // EventLoop Lifecycle
    state: EventLoopState,

    start: ?*const fn (el: ?*EventLoop) callconv(.c) StatusCode,
    stop: ?*const fn (el: ?*EventLoop) callconv(.c) void,
    free: ?*const fn (el: ?*EventLoop) callconv(.c) StatusCode,
    run: ?*const fn (el: ?*EventLoop, timeout: u32) callconv(.c) StatusCode,
    cancel: ?*const fn (el: ?*EventLoop) callconv(.c) void,

    // EventLoop Time Domain
    dateTime_now: ?*const fn (el: ?*EventLoop) callconv(.c) DateTime,
    dateTime_nowMonotonic: ?*const fn (el: ?*EventLoop) callconv(.c) DateTime,
    dateTime_localTimeUtcOffset: ?*const fn (el: ?*EventLoop) callconv(.c) i64,

    // Timer Callbacks
    nextTimer: ?*const fn (el: ?*EventLoop) callconv(.c) DateTime,
    addTimer: ?*const fn (
        el: ?*EventLoop,
        cb: Callback,
        application: ?*anyopaque,
        data: ?*anyopaque,
        interval_ms: f64,
        baseTime: ?*DateTime,
        timerPolicy: TimerPolicy,
        timerId: ?*u64,
    ) callconv(.c) StatusCode,

    modifyTimer: ?*const fn (
        el: ?*EventLoop,
        timerId: u64,
        interval_ms: f64,
        baseTime: ?*DateTime,
        timerPolicy: TimerPolicy,
    ) callconv(.c) StatusCode,

    removeTimer: ?*const fn (el: ?*EventLoop, timerId: u64) callconv(.c) void,

    // Delayed Callbacks
    addDelayedCallback: ?*const fn (el: ?*EventLoop, dc: ?*DelayedCallback) callconv(.c) void,
    removeDelayedCallback: ?*const fn (el: ?*EventLoop, dc: ?*DelayedCallback) callconv(.c) void,

    // EventSources
    eventSources: ?*EventSource,
    registerEventSource: ?*const fn (el: ?*EventLoop, es: ?*EventSource) callconv(.c) StatusCode,
    deregisterEventSource: ?*const fn (el: ?*EventLoop, es: ?*EventSource) callconv(.c) StatusCode,

    // Locking
    lock: ?*const fn (el: ?*EventLoop) callconv(.c) void,
    unlock: ?*const fn (el: ?*EventLoop) callconv(.c) void,
};

// Message Security Mode

pub const MessageSecurityMode = enum(c_int) {
    INVALID = 0,
    NONE = 1,
    SIGN = 2,
    SIGNANDENCRYPT = 3,
    /// Force the enum to be 32-bit (corresponds to 0x7fffffff in C)
    _,
};

// Connection State

pub const ConnectionState = enum(c_int) {
    /// The socket has been closed and the connection will be deleted
    CLOSED = 0,
    /// The socket is open, but the connection not yet fully established
    OPENING = 1,
    /// The socket is open and the connection configured
    ESTABLISHED = 2,
    /// The socket is closing down
    CLOSING = 3,
    /// Listening disabled (e.g. max connections reached)
    BLOCKING = 4,
    /// Listening resumed after being blocked
    REOPENING = 5,
};

pub const SecureChannelState = enum(c_int) {
    CLOSED = 0,
    REVERSE_LISTENING = 1,
    CONNECTING = 2,
    CONNECTED = 3,
    REVERSE_CONNECTED = 4,
    RHE_SENT = 5,
    HEL_SENT = 6,
    HEL_RECEIVED = 7,
    ACK_SENT = 8,
    ACK_RECEIVED = 9,
    OPN_SENT = 10,
    OPEN = 11,
    CLOSING = 12,
};

pub const SessionState = enum(c_int) {
    CLOSED = 0,
    CREATE_REQUESTED = 1,
    CREATED = 2,
    ACTIVATE_REQUESTED = 3,
    ACTIVATED = 4,
    CLOSING = 5,
};

// Statistics Counters

pub const ShutdownReason = enum(c_int) {
    CLOSE = 0,
    REJECT = 1,
    SECURITYREJECT = 2,
    TIMEOUT = 3,
    ABORT = 4,
    PURGE = 5,
};

pub const SecureChannelStatistics = extern struct {
    currentChannelCount: usize,
    cumulatedChannelCount: usize,
    rejectedChannelCount: usize,
    /// Only used by servers
    channelTimeoutCount: usize,
    channelAbortCount: usize,
    /// Only used by servers
    channelPurgeCount: usize,
};

pub const SessionStatistics = extern struct {
    currentSessionCount: usize,
    cumulatedSessionCount: usize,
    /// Only used by servers
    securityRejectedSessionCount: usize,
    rejectedSessionCount: usize,
    /// Only used by servers
    sessionTimeoutCount: usize,
    /// Only used by servers
    sessionAbortCount: usize,
};

// Connection Config

pub const ConnectionConfig = extern struct {
    protocolVersion: u32,
    recvBufferSize: u32,
    sendBufferSize: u32,
    /// (0 = unbounded)
    localMaxMessageSize: u32,
    /// (0 = unbounded)
    remoteMaxMessageSize: u32,
    /// (0 = unbounded)
    localMaxChunkCount: u32,
    /// (0 = unbounded)
    remoteMaxChunkCount: u32,
};

// Connection Manager

pub const ConnectionManager_connectionCallback = ?*const fn (
    cm: ?*ConnectionManager,
    connectionId: usize,
    application: ?*anyopaque,
    context: ?*anyopaque,
    status: ConnectionState,
    params: ?*const KeyValueMap,
    buf: ?*String,
) callconv(.c) void;

pub const ConnectionManager = extern struct {
    /// Every ConnectionManager is treated like an EventSource from the
    /// perspective of the EventLoop.
    eventSource: EventSource,

    /// Name of the protocol supported by the ConnectionManager.
    protocol: String,

    /// Open a Connection
    /// Connecting is asynchronous. The connection-callback is called when the
    /// connection is open or aborted.
    openConnection: ?*const fn (
        cm: ?*ConnectionManager,
        params: ?*const KeyValueMap,
        application: ?*anyopaque,
        context: ?*anyopaque,
        connectionCallback: ConnectionManager_connectionCallback,
    ) callconv(.c) StatusCode,

    /// Send a message over a Connection
    /// Sending is asynchronous. The memory for the buffer is released internally.
    sendWithConnection: ?*const fn (
        cm: ?*ConnectionManager,
        connectionId: usize,
        params: ?*const KeyValueMap,
        buf: ?*String,
    ) callconv(.c) StatusCode,

    /// Close a Connection
    closeConnection: ?*const fn (
        cm: ?*ConnectionManager,
        connectionId: usize,
    ) callconv(.c) StatusCode,

    /// Buffer Management
    allocNetworkBuffer: ?*const fn (
        cm: ?*ConnectionManager,
        connectionId: usize,
        buf: ?*String,
        bufSize: usize,
    ) callconv(.c) StatusCode,

    freeNetworkBuffer: ?*const fn (
        cm: ?*ConnectionManager,
        connectionId: usize,
        buf: ?*String,
    ) callconv(.c) void,
};

// Namespace Mapping

pub const NamespaceMapping = extern struct {
    /// Namespaces with their local index
    namespaceUris: ?[*]String,
    namespaceUrisSize: usize,

    /// Map from local to remote indices
    local2remote: ?[*]u16,
    local2remoteSize: usize,

    /// Map from remote to local indices
    remote2local: ?[*]u16,
    remote2localSize: usize,
};

// ChannelSecurityToken
pub const ChannelSecurityToken = extern struct {
    channelId: u32,
    tokenId: u32,
    createdAt: i64, // DateTime is i64
    revisedLifetime: u32,
};

// Security Policy

pub const SecurityPolicySignatureAlgorithm = extern struct {
    uri: String,

    verify: ?*const fn (
        policy: ?*const SecurityPolicy,
        channelContext: ?*anyopaque,
        message: ?*const String,
        signature: ?*const String,
    ) callconv(.c) StatusCode,

    sign: ?*const fn (
        policy: ?*const SecurityPolicy,
        channelContext: ?*anyopaque,
        message: ?*const String,
        signature: ?*String,
    ) callconv(.c) StatusCode,

    getLocalSignatureSize: ?*const fn (
        policy: ?*const SecurityPolicy,
        channelContext: ?*const anyopaque,
    ) callconv(.c) usize,

    getRemoteSignatureSize: ?*const fn (
        policy: ?*const SecurityPolicy,
        channelContext: ?*const anyopaque,
    ) callconv(.c) usize,

    getLocalKeyLength: ?*const fn (
        policy: ?*const SecurityPolicy,
        channelContext: ?*const anyopaque,
    ) callconv(.c) usize,

    getRemoteKeyLength: ?*const fn (
        policy: ?*const SecurityPolicy,
        channelContext: ?*const anyopaque,
    ) callconv(.c) usize,
};

pub const SecurityPolicyEncryptionAlgorithm = extern struct {
    uri: String,

    encrypt: ?*const fn (
        policy: ?*const SecurityPolicy,
        channelContext: ?*anyopaque,
        data: ?*String,
    ) callconv(.c) StatusCode,

    decrypt: ?*const fn (
        policy: ?*const SecurityPolicy,
        channelContext: ?*anyopaque,
        data: ?*String,
    ) callconv(.c) StatusCode,

    getLocalKeyLength: ?*const fn (
        policy: ?*const SecurityPolicy,
        channelContext: ?*const anyopaque,
    ) callconv(.c) usize,

    getRemoteKeyLength: ?*const fn (
        policy: ?*const SecurityPolicy,
        channelContext: ?*const anyopaque,
    ) callconv(.c) usize,

    getRemoteBlockSize: ?*const fn (
        policy: ?*const SecurityPolicy,
        channelContext: ?*const anyopaque,
    ) callconv(.c) usize,

    getRemotePlainTextBlockSize: ?*const fn (
        policy: ?*const SecurityPolicy,
        channelContext: ?*const anyopaque,
    ) callconv(.c) usize,

    getLocalIvLength: ?*const fn (
        policy: ?*const SecurityPolicy,
        channelContext: ?*const anyopaque,
    ) callconv(.c) usize,
};

pub const SecurityPolicyType = enum(c_int) {
    NONE = 0,
    RSA = 1,
    ECC = 2,
    ECC_AEAD = 3,
};

pub const SecurityPolicy = extern struct {
    policyContext: ?*anyopaque,
    logger: ?*const Logger,
    policyUri: String,
    securityLevel: u8,
    policyType: SecurityPolicyType,
    localCertificate: String,
    certificateGroupId: NodeId,
    certificateTypeId: NodeId,

    // Modules
    asymSignatureAlgorithm: SecurityPolicySignatureAlgorithm,
    asymEncryptionAlgorithm: SecurityPolicyEncryptionAlgorithm,
    symSignatureAlgorithm: SecurityPolicySignatureAlgorithm,
    symEncryptionAlgorithm: SecurityPolicyEncryptionAlgorithm,
    certSignatureAlgorithm: SecurityPolicySignatureAlgorithm,

    // Lifecycle and Key Management
    newChannelContext: ?*const fn (
        policy: ?*const SecurityPolicy,
        remoteCertificate: ?*const String,
        channelContext: ?*?*anyopaque,
    ) callconv(.c) StatusCode,

    deleteChannelContext: ?*const fn (
        policy: ?*const SecurityPolicy,
        channelContext: ?*anyopaque,
    ) callconv(.c) void,

    setLocalSymEncryptingKey: ?*const fn (
        policy: ?*const SecurityPolicy,
        channelContext: ?*anyopaque,
        key: ?*const String,
    ) callconv(.c) StatusCode,

    setLocalSymSigningKey: ?*const fn (
        policy: ?*const SecurityPolicy,
        channelContext: ?*anyopaque,
        key: ?*const String,
    ) callconv(.c) StatusCode,

    setLocalSymIv: ?*const fn (
        policy: ?*const SecurityPolicy,
        channelContext: ?*anyopaque,
        iv: ?*const String,
    ) callconv(.c) StatusCode,

    setRemoteSymEncryptingKey: ?*const fn (
        policy: ?*const SecurityPolicy,
        channelContext: ?*anyopaque,
        key: ?*const String,
    ) callconv(.c) StatusCode,

    setRemoteSymSigningKey: ?*const fn (
        policy: ?*const SecurityPolicy,
        channelContext: ?*anyopaque,
        key: ?*const String,
    ) callconv(.c) StatusCode,

    setRemoteSymIv: ?*const fn (
        policy: ?*const SecurityPolicy,
        channelContext: ?*anyopaque,
        iv: ?*const String,
    ) callconv(.c) StatusCode,

    setMessageSecurityParameters: ?*const fn (
        policy: ?*const SecurityPolicy,
        channelContext: ?*anyopaque,
        tokenId: u32,
        previousSequenceNumber: u32,
        additionalAuthData: ?*const String,
    ) callconv(.c) StatusCode,

    compareCertificate: ?*const fn (
        policy: ?*const SecurityPolicy,
        channelContext: ?*const anyopaque,
        certificate: ?*const String,
    ) callconv(.c) StatusCode,

    generateKey: ?*const fn (
        policy: ?*const SecurityPolicy,
        channelContext: ?*anyopaque,
        secret: ?*const String,
        seed: ?*const String,
        out: ?*String,
    ) callconv(.c) StatusCode,

    generateNonce: ?*const fn (
        policy: ?*const SecurityPolicy,
        channelContext: ?*anyopaque,
        out: ?*String,
    ) callconv(.c) StatusCode,

    nonceLength: usize,

    makeCertThumbprint: ?*const fn (
        policy: ?*const SecurityPolicy,
        certificate: ?*const String,
        thumbprint: ?*String,
    ) callconv(.c) StatusCode,

    compareCertThumbprint: ?*const fn (
        policy: ?*const SecurityPolicy,
        thumbprint: ?*const String,
    ) callconv(.c) StatusCode,

    updateCertificate: ?*const fn (
        policy: ?*SecurityPolicy,
        certificate: String,
        privateKey: String,
    ) callconv(.c) StatusCode,

    createSigningRequest: ?*const fn (
        policy: ?*SecurityPolicy,
        subjectName: ?*const String,
        nonce: ?*const String,
        params: ?*const KeyValueMap,
        csr: ?*String,
        newPrivateKey: ?*String,
    ) callconv(.c) StatusCode,

    clear: ?*const fn (policy: ?*SecurityPolicy) callconv(.c) void,
};

// Secure Channel Structure

pub const SecureChannelRenewState = enum(c_int) {
    NORMAL = 0,
    /// Client has sent an OPN, but not received a response so far.
    SENT = 1,
    /// The server waits for the first request with the new token for the rollover.
    NEWTOKEN_SERVER = 2,
    /// The client already uses the new token. But he waits for the server to respond
    /// with the new token to complete the rollover.
    NEWTOKEN_CLIENT = 3,
};

pub const SecureChannel = extern struct {
    state: SecureChannelState,
    renewState: SecureChannelRenewState,
    securityMode: MessageSecurityMode,
    shutdownReason: ShutdownReason,

    config: ConnectionConfig,
    endpointUrl: String,
    remoteAddress: String,

    // Connection handling in the EventLoop
    connectionManager: ?*ConnectionManager,
    connectionId: usize, // uintptr_t maps to usize in Zig

    // The namespace mapping translates namespace indices (client only)
    namespaceMapping: ?*NamespaceMapping,

    // Linked lists (only used in the server)
    // serverEntry and componentEntry are BSD TAILQ_ENTRY structures
    serverEntry: TailQEntry(SecureChannel),
    componentEntry: TailQEntry(SecureChannel),

    securityToken: ChannelSecurityToken,
    /// Alternative token for the rollover. See the renewState.
    altSecurityToken: ChannelSecurityToken,

    // The endpoint and context of the channel
    securityPolicy: ?*SecurityPolicy,
    channelContext: ?*anyopaque,

    // Asymmetric encryption info
    remoteCertificate: String,
    remoteCertificateThumbprint: [20]u8,

    // Symmetric encryption nonces
    remoteNonce: String,
    localNonce: String,

    receiveSequenceNumber: u32,
    sendSequenceNumber: u32,

    // Sessions bound to the SecureChannel (server only)
    sessions: ?*Session,

    // (Decrypted) chunks waiting to be processed
    chunks: ChunkQueue,
    chunksCount: usize,
    chunksLength: usize,

    // Received buffer from which no chunks have been extracted so far
    unprocessed: String,
    unprocessedOffset: usize,
    unprocessedCopied: bool,
    unprocessedDelayed: DelayedCallback,

    processOPNHeaderApplication: ?*anyopaque,
    processOPNHeader: ?*const fn (
        application: ?*anyopaque,
        channel: ?*SecureChannel,
        asymHeader: ?*const AsymmetricAlgorithmSecurityHeader,
    ) callconv(.c) StatusCode,
};

pub const AsymmetricAlgorithmSecurityHeader = extern struct {
    securityPolicyUri: String,
    senderCertificate: String,
    receiverCertificateThumbprint: String,
};

pub const MessageType = enum(u32) {
    ACK = 0x4B4341,
    HEL = 0x4C4548,
    MSG = 0x47534D,
    OPN = 0x4E504F,
    CLO = 0x4F4C43,
    ERR = 0x525245,
    RHE = 0x454852,
    INVALID = 0x0,
    /// Force the enum to be 32-bit (corresponds to 0x7fffffff in C)
    _,
};

pub const ChunkType = enum(u32) {
    FINAL = 0x46000000,
    INTERMEDIATE = 0x43000000,
    ABORT = 0x41000000,
    /// Force the enum to be 32-bit (corresponds to 0x7fffffff in C)
    _,
};

pub const Chunk = extern struct {
    /// TAILQ_ENTRY for linking chunks in a queue
    pointers: TailQEntry(Chunk),
    bytes: String,
    messageType: MessageType,
    chunkType: ChunkType,
    requestId: u32,
    /// Do the bytes point to a buffer from the network or was
    /// memory allocated for the chunk separately
    copied: bool,
};

pub const ChunkQueue = TailQHead(Chunk);

// Session Structure

pub const Session = extern struct {
    next: ?*Session, // Singly-linked list
    channel: ?*SecureChannel, // Pointer back to the SecureChannel

    sessionId: NodeId,
    authenticationToken: NodeId,
    sessionName: String,
    activated: bool,

    sessionSp: ?*SecurityPolicy,
    sessionSpContext: ?*anyopaque,

    context: ?*anyopaque, // User-assigned pointer

    serverNonce: String, // ByteString is an alias for String

    clientDescription: ApplicationDescription,
    clientCertificate: String,
    clientUserIdOfSession: String,
    timeout: f64, // Double in ms
    validTill: i64, // DateTime is i64

    attributes: KeyValueMap,

    // Currently unused according to C header
    maxRequestMessageSize: u32,
    maxResponseMessageSize: u32,

    availableContinuationPoints: u16,
    continuationPoints: ?*ContinuationPoint,

    // Localization
    localeIdsSize: usize,
    localeIds: ?[*]String,

    // Subscription Management
    subscriptionsSize: usize,
    subscriptions: TailQHead(Subscription),

    responseQueueSize: usize,
    responseQueue: SimpleQHead(PublishResponseEntry),

    totalRetransmissionQueueSize: usize,

    // Diagnostics
    securityDiagnostics: SessionSecurityDiagnosticsDataType,
    diagnostics: SessionDiagnosticsDataType,
};

pub const SessionDiagnosticsDataType = extern struct {
    sessionId: NodeId,
    sessionName: String,
    clientDescription: ApplicationDescription,
    serverUri: String,
    endpointUrl: String,
    localeIdsSize: usize,
    localeIds: ?[*]String,
    actualSessionTimeout: f64,
    maxResponseMessageSize: u32,
    clientConnectionTime: i64,
    clientLastContactTime: i64,
    currentSubscriptionsCount: u32,
    currentMonitoredItemsCount: u32,
    currentPublishRequestsInQueue: u32,
    totalRequestCount: ServiceCounterDataType,
    unauthorizedRequestCount: u32,
    readCount: ServiceCounterDataType,
    historyReadCount: ServiceCounterDataType,
    writeCount: ServiceCounterDataType,
    historyUpdateCount: ServiceCounterDataType,
    callCount: ServiceCounterDataType,
    createMonitoredItemsCount: ServiceCounterDataType,
    modifyMonitoredItemsCount: ServiceCounterDataType,
    setMonitoringModeCount: ServiceCounterDataType,
    setTriggeringCount: ServiceCounterDataType,
    deleteMonitoredItemsCount: ServiceCounterDataType,
    createSubscriptionCount: ServiceCounterDataType,
    modifySubscriptionCount: ServiceCounterDataType,
    setPublishingModeCount: ServiceCounterDataType,
    publishCount: ServiceCounterDataType,
    republishCount: ServiceCounterDataType,
    transferSubscriptionsCount: ServiceCounterDataType,
    deleteSubscriptionsCount: ServiceCounterDataType,
    addNodesCount: ServiceCounterDataType,
    addReferencesCount: ServiceCounterDataType,
    deleteNodesCount: ServiceCounterDataType,
    deleteReferencesCount: ServiceCounterDataType,
    browseCount: ServiceCounterDataType,
    browseNextCount: ServiceCounterDataType,
    translateBrowsePathsToNodeIdsCount: ServiceCounterDataType,
    queryFirstCount: ServiceCounterDataType,
    queryNextCount: ServiceCounterDataType,
    registerNodesCount: ServiceCounterDataType,
    unregisterNodesCount: ServiceCounterDataType,
};

pub const ServiceCounterDataType = extern struct {
    totalCount: u32,
    errorCount: u32,
};

pub const SessionSecurityDiagnosticsDataType = extern struct {
    sessionId: NodeId,
    clientUserIdOfSession: String,
    clientUserIdHistorySize: usize,
    clientUserIdHistory: ?[*]String,
    authenticationMechanism: String,
    encoding: String,
    transportProtocol: String,
    securityMode: MessageSecurityMode,
    securityPolicyUri: String,
    clientCertificate: ByteString,
};

pub const PublishResponseEntry = extern struct {
    /// SIMPLEQ_ENTRY for linking responses in a queue
    listEntry: SimpleQEntry(PublishResponseEntry),
    requestId: u32,
    /// Based on the TimeoutHint of the request
    maxTime: i64, // DateTime is i64
    response: PublishResponse,
};

pub const PublishResponse = extern struct {
    responseHeader: ResponseHeader,
    subscriptionId: u32,
    availableSequenceNumbersSize: usize,
    availableSequenceNumbers: ?[*]u32,
    moreNotifications: bool,
    notificationMessage: NotificationMessage,
    resultsSize: usize,
    results: ?[*]StatusCode,
    diagnosticInfosSize: usize,
    diagnosticInfos: ?[*]DiagnosticInfo,
};

pub const DiagnosticInfo = extern struct {
    flags: packed struct(u8) {
        hasSymbolicId: bool,
        hasNamespaceUri: bool,
        hasLocalizedText: bool,
        hasLocale: bool,
        hasAdditionalInfo: bool,
        hasInnerStatusCode: bool,
        hasInnerDiagnosticInfo: bool,
        _: u1 = 0,
    },
    symbolicId: i32,
    namespaceUri: i32,
    localizedText: i32,
    locale: i32,
    additionalInfo: String,
    innerStatusCode: StatusCode,
    innerDiagnosticInfo: ?*DiagnosticInfo,
};

pub const NotificationMessage = extern struct {
    sequenceNumber: u32,
    publishTime: i64, // DateTime is i64
    notificationDataSize: usize,
    notificationData: ?[*]ExtensionObject,
};

pub const ResponseHeader = extern struct {
    timestamp: i64, // DateTime is i64
    requestHandle: u32,
    serviceResult: StatusCode,
    serviceDiagnostics: DiagnosticInfo,
    stringTableSize: usize,
    stringTable: ?[*]String,
    additionalHeader: ExtensionObject,
};

pub const ContinuationPoint = String;

// Notification Structure

pub const Notification = extern struct {
    /// Notification list of the Subscription
    subEntry: TailQEntry(Notification),
    /// Notification list of the MonitoredItem
    monEntry: TailQEntry(Notification),
    /// Always set
    mon: *MonitoredItem,

    data: extern union {
        dataChange: MonitoredItemNotification,
        // event: EventFieldList, // Enable if UA_ENABLE_SUBSCRIPTIONS_EVENTS is defined
    },

    // isOverflowEvent: bool, // Enable if UA_ENABLE_SUBSCRIPTIONS_EVENTS is defined
};

pub const MonitoredItemNotification = extern struct {
    clientHandle: u32,
    value: DataValue,
};

pub const NotificationMessageEntry = extern struct {
    listEntry: TailQEntry(NotificationMessageEntry),
    message: NotificationMessage,
};

pub const DataValue = extern struct {
    value: Variant,
    sourceTimestamp: i64,
    serverTimestamp: i64,
    sourcePicoseconds: u16,
    serverPicoseconds: u16,
    status: StatusCode,
    flags: packed struct(u16) {
        hasValue: bool,
        hasStatus: bool,
        hasSourceTimestamp: bool,
        hasServerTimestamp: bool,
        hasSourcePicoseconds: bool,
        hasServerPicoseconds: bool,
        _: u10 = 0,
    },
};

/// Queue Definitions
pub const NotificationQueue = TailQHead(Notification);
pub const NotificationMessageQueue = TailQHead(NotificationMessageEntry);

// Subscription Structure

pub const SubscriptionState = enum(c_int) {
    STOPPED = 0,
    REMOVING = 1,
    ENABLED_NOPUBLISH = 2, // only keepalive
    ENABLED = 3,
};

pub const Subscription = extern struct {
    delayedFreePointers: DelayedCallback,
    serverListEntry: ListEntry(Subscription),
    /// Ordered according to the priority byte and round-robin scheduling for
    /// late subscriptions. Only set if session != NULL.
    sessionListEntry: TailQEntry(Subscription),
    session: ?*Session, // May be NULL if no session is attached.
    subscriptionId: u32,

    // Settings
    lifeTimeCount: u32,
    maxKeepAliveCount: u32,
    publishingInterval: f64, // in ms
    notificationsPerPublish: u32,
    priority: u8,

    // Runtime information
    state: SubscriptionState,
    late: bool,
    /// Set to true when this subscription was transferred to another session.
    wasTransferred: bool,
    /// If set, a notification is generated and the Subscription is deleted.
    statusChange: StatusCode,
    nextSequenceNumber: u32,
    currentKeepAliveCount: u32,
    currentLifetimeCount: u32,

    /// Publish Callback. Registered if id > 0.
    publishCallbackId: u64,

    // Delayed callback to schedule publication of more notifications
    delayedCallbackRegistered: bool,
    delayedMoreNotifications: DelayedCallback,

    // MonitoredItems
    lastMonitoredItemId: u32,
    monitoredItems: ListHead(MonitoredItem),
    monitoredItemsSize: u32,

    /// MonitoredItems that are sampled in every publish callback
    samplingMonitoredItems: ListHead(MonitoredItem),

    // Global list of notifications from the MonitoredItems
    notificationQueue: TailQHead(Notification),
    notificationQueueSize: u32,
    dataChangeNotifications: u32,
    eventNotifications: u32,

    // Retransmission Queue
    retransmissionQueue: NotificationMessageQueue,
    retransmissionQueueSize: usize,

    // Diagnostics (Optional based on UA_ENABLE_DIAGNOSTICS)
    // Note: In Zig, you can wrap these in a conditional or include them
    // depending on your build configuration.
    ns0Id: NodeId,
    modifyCount: u32,
    enableCount: u32,
    disableCount: u32,
    republishRequestCount: u32,
    republishMessageCount: u32,
    transferRequestCount: u32,
    transferredToAltClientCount: u32,
    transferredToSameClientCount: u32,
    publishRequestCount: u32,
    dataChangeNotificationsCount: u32,
    eventNotificationsCount: u32,
    notificationsCount: u32,
    latePublishRequestCount: u32,
    discardedMessageCount: u32,
    monitoringQueueOverflowCount: u32,
    eventQueueOverflowCount: u32,
};

// Monitored Item Structure

pub const MonitoredItemSamplingType = enum(c_int) {
    NONE = 0,
    /// Cyclic callback
    CYCLIC = 1,
    /// Attached to the node. Can be a "write event" for DataChange MonitoredItems
    /// with a zero sampling interval.
    EVENT = 2,
    /// Attached to the subscription
    PUBLISH = 3,
};

pub const MonitoringMode = enum(c_int) {
    DISABLED = 0,
    SAMPLING = 1,
    REPORTING = 2,
    /// Force the enum to be 32-bit as per C standard if necessary
    FORCE32BIT = 0x7fffffff,
};

pub const TimestampsToReturn = enum(c_int) {
    SOURCE = 0,
    SERVER = 1,
    BOTH = 2,
    NEITHER = 3,
    INVALID = 4,
    FORCE32BIT = 0x7fffffff,
};

pub const MonitoringParameters = extern struct {
    clientHandle: u32,
    samplingInterval: f64,
    filter: ExtensionObject,
    queueSize: u32,
    discardOldest: bool,
};

pub const MonitoredItem = extern struct {
    delayedFreePointers: DelayedCallback,
    /// Linked list in the Subscription
    listEntry: ListEntry(MonitoredItem),
    /// Always non-NULL
    subscription: *Subscription,
    monitoredItemId: u32,

    // Status and Settings
    itemToMonitor: ReadValueId,
    monitoringMode: MonitoringMode,
    timestampsToReturn: TimestampsToReturn,
    /// Registered in the server / Subscription
    registered: bool,
    /// If the MonitoringMode is SAMPLING, triggering the MonitoredItem puts the
    /// latest Notification into the publishing queue.
    triggeredUntil: i64,

    parameters: MonitoringParameters,

    // Sampling
    samplingType: MonitoredItemSamplingType,
    sampling: extern union {
        callbackId: u64,
        /// Event-Based: Attached to Node
        nodeListNext: ?*MonitoredItem,
        /// Linked to publish interval
        subscriptionSampling: ListEntry(MonitoredItem),
    },
    lastValue: DataValue,
    outstandingAsyncReads: u32,

    // Triggering Links
    triggeringLinksSize: usize,
    triggeringLinks: ?[*]u32,

    // Notification Queue
    queue: NotificationQueue,
    /// Current size. See also configured queueSize in parameters.
    queueSize: usize,
    /// Separate counter for the queue.
    eventOverflows: usize,
};

// Async

pub const CallMethodResult = extern struct {
    statusCode: StatusCode,
    inputArgumentResultsSize: usize,
    inputArgumentResults: ?[*]StatusCode,
    inputArgumentDiagnosticInfosSize: usize,
    inputArgumentDiagnosticInfos: ?[*]DiagnosticInfo,
    outputArgumentsSize: usize,
    outputArguments: ?[*]Variant,
};

pub const WriteValue = extern struct {
    nodeId: NodeId,
    attributeId: u32,
    indexRange: String,
    value: DataValue,
};

pub const AsyncOperationType = enum(c_int) {
    CALL_REQUEST = 0,
    READ_REQUEST = 1,
    WRITE_REQUEST = 2,
    CALL_DIRECT = 0 + 4,
    READ_DIRECT = 1 + 4,
    WRITE_DIRECT = 2 + 4,
};

pub const AsyncOperation = extern struct {
    pointers: TailQEntry(AsyncOperation),
    asyncOperationType: AsyncOperationType,

    handling: extern union {
        /// The operation is part of a service request
        response: ?*AsyncResponse,

        /// The operation was called directly
        callback: extern struct {
            timeout: i64,
            context: ?*anyopaque,
            method: extern union {
                read: ?*const fn (server: *Server, requestId: u32, requestHandle: u32, context: ?*anyopaque, result: *DataValue) callconv(.c) void,
                write: ?*const fn (server: *Server, requestId: u32, requestHandle: u32, context: ?*anyopaque, result: *StatusCode) callconv(.c) void,
                call: ?*const fn (server: *Server, requestId: u32, requestHandle: u32, context: ?*anyopaque, result: *CallMethodResult) callconv(.c) void,
            },
        },
    },

    output: extern union {
        call: ?*CallMethodResult,
        write: ?*StatusCode,
        read: ?*DataValue,
        directCall: CallMethodResult,
        directWrite: StatusCode,
        directRead: DataValue,
    },

    context: extern union {
        writeValue: WriteValue,
    },
};

pub const CallResponse = extern struct {
    responseHeader: ResponseHeader,
    resultsSize: usize,
    results: ?[*]CallMethodResult,
    diagnosticInfosSize: usize,
    diagnosticInfos: ?[*]DiagnosticInfo,
};

pub const ReadResponse = extern struct {
    responseHeader: ResponseHeader,
    resultsSize: usize,
    results: ?[*]DataValue,
    diagnosticInfosSize: usize,
    diagnosticInfos: ?[*]DiagnosticInfo,
};

pub const WriteResponse = extern struct {
    responseHeader: ResponseHeader,
    resultsSize: usize,
    results: ?[*]StatusCode,
    diagnosticInfosSize: usize,
    diagnosticInfos: ?[*]DiagnosticInfo,
};

pub const AsyncResponse = extern struct {
    pointers: TailQEntry(AsyncResponse),

    requestId: u32,
    requestHandle: u32,
    timeout: i64,
    sessionId: NodeId,
    /// Counter for outstanding operations
    opCountdown: u32,

    responseType: ?*const DataType,
    response: extern union {
        callResponse: CallResponse,
        readResponse: ReadResponse,
        writeResponse: WriteResponse,
    },
};

pub const AsyncManager = extern struct {
    currentRequestId: u32,
    currentRequestHandle: u32,

    waitingResponses: TailQHead(AsyncResponse),
    readyResponses: TailQHead(AsyncResponse),

    waitingOps: TailQHead(AsyncOperation),
    readyOps: TailQHead(AsyncOperation),
    opsCount: usize,

    checkTimeoutCallbackId: u64,

    dc: DelayedCallback,
};

// Server Structure

pub const DataTypeArray = extern struct {
    next: ?*DataTypeArray,
    typesSize: usize,
    types: ?[*]DataType,
    /// Free the array structure and its content when the client or server
    /// configuration containing it is cleaned up
    cleanup: bool,
};

pub const ServerDiagnosticsSummaryDataType = extern struct {
    serverViewCount: u32,
    currentSessionCount: u32,
    cumulatedSessionCount: u32,
    securityRejectedSessionCount: u32,
    rejectedSessionCount: u32,
    sessionTimeoutCount: u32,
    sessionAbortCount: u32,
    currentSubscriptionCount: u32,
    cumulatedSubscriptionCount: u32,
    publishingIntervalCount: u32,
    securityRejectedRequestsCount: u32,
    rejectedRequestsCount: u32,
};

pub const SessionListEntry = extern struct {
    cleanupCallback: DelayedCallback,
    pointers: ListEntry(SessionListEntry),
    session: Session,
};

pub const LifecycleState = enum(c_int) {
    STOPPED = 0,
    STARTED = 1,
    STOPPING = 2,
};

pub const ServerComponentType = enum(c_int) {
    NORMAL = 0,
};

pub const ServerComponent = extern struct {
    /// linked-list
    next: ?*ServerComponent,
    serverComponentType: ServerComponentType,

    name: String,
    state: LifecycleState,

    /// Backpointer to the server. Needs to be set before the ServerComponent is started.
    server: ?*Server,

    /// Start the ServerComponent.
    start: ?*const fn (sc: *ServerComponent) callconv(.c) StatusCode,

    /// Stopping is asynchronous and might need a few iterations of the eventloop to succeed.
    stop: ?*const fn (sc: *ServerComponent) callconv(.c) void,

    /// Clean up and delete the ServerComponent.
    free: ?*const fn (sc: *ServerComponent) callconv(.c) StatusCode,
};

pub const Lock = extern struct {
    mutex: c.pthread_mutex_t,
    /// For assertions that we hold the mutex
    count: c_uint,
};

pub const Server = extern struct {
    // Config
    config: ServerConfig,

    // Runtime state
    startTime: DateTime,
    endTime: DateTime,

    state: LifecycleState,
    houseKeepingCallbackId: u64,

    // Server Components
    components: ?*ServerComponent,
    binarySC: ?*ServerComponent,
    discoverySC: ?*ServerComponent,
    pubSubSC: ?*ServerComponent,

    asyncManager: AsyncManager,

    customTypes_internal: ?*DataTypeArray,
    customTypes_internalSize: usize,

    // Session Management
    sessions: ListHead(SessionListEntry),
    sessionCount: u32,
    activeSessionCount: u32,

    adminSession: Session,

    // SecureChannels
    channels: TailQHead(SecureChannel),
    lastChannelId: u32,
    lastTokenId: u32,

    // Namespaces
    namespacesSize: usize,
    namespaces: ?[*]String,

    bootstrapNS0: bool,

    // Subscriptions
    adminSubscription: ?*Subscription,
    subscriptionsSize: usize,
    monitoredItemsSize: usize,
    subscriptions: ListHead(Subscription),
    lastSubscriptionId: u32,

    // Multithreading
    serviceMutex: Lock,

    // Statistics
    secureChannelStatistics: SecureChannelStatistics,
    serverDiagnosticsSummary: ServerDiagnosticsSummaryDataType,

    // GDS Manager
    gdsManager: GDSManager,
};

pub const BuildInfo = extern struct {
    productUri: String,
    manufacturerName: String,
    productName: String,
    softwareVersion: String,
    buildNumber: String,
    buildDate: i64,
};

pub const RuleHandling = enum(c_int) {
    DEFAULT = 0,
    /// Abort the operation and return an error code
    ABORT = 1,
    /// Print a message in the logs and continue
    WARN = 2,
    /// Continue and disregard the broken rule
    ACCEPT = 3,
};

pub const ApplicationNotificationType = enum(c_int) {
    /// Lifetime notifications
    LIFECYCLE_STARTED = 0x0,
    LIFECYCLE_SHUTDOWN = 0x01,
    LIFECYCLE_STOPPING = 0x02,
    LIFECYCLE_STOPPED = 0x03,

    /// SecureChannel notifications
    SECURECHANNEL_OPENED = 0x04,
    SECURECHANNEL_CLOSED = 0x05,

    /// Session notifications
    SESSION_CREATED = 0x06,
    SESSION_ACTIVATED = 0x07,
    SESSION_DEACTIVATED = 0x08,
    SESSION_CLOSED = 0x09,

    /// Service processing notifications
    SERVICE_BEGIN = 0x10,
    SERVICE_ASYNC = 0x11,
    SERVICE_END = 0x12,

    /// Subscription notifications
    SUBSCRIPTION_CREATED = 0x13,
    SUBSCRIPTION_MODIFIED = 0x14,
    SUBSCRIPTION_PUBLISHINGMODE = 0x15,
    SUBSCRIPTION_TRANSFERRED = 0x16,
    SUBSCRIPTION_DELETED = 0x17,

    /// MonitoredItem notifications
    MONITOREDITEM_CREATED = 0x18,
    MONITOREDITEM_MODIFIED = 0x19,
    MONITOREDITEM_MONITORINGMODE = 0x1a,
    MONITOREDITEM_DELETE = 0x1b,

    /// Audit events (bitfield hierarchy)
    AUDIT = 0x1000,
    AUDIT_SECURITY = 0x1100,
    AUDIT_SECURITY_CHANNEL = 0x1110,
    AUDIT_SECURITY_CHANNEL_OPEN = 0x1111,
    AUDIT_SECURITY_SESSION = 0x1120,
    AUDIT_SECURITY_SESSION_CREATE = 0x1121,
    AUDIT_SECURITY_SESSION_ACTIVATE = 0x1122,
    AUDIT_SECURITY_SESSION_CANCEL = 0x1124,
    AUDIT_SECURITY_CERTIFICATE = 0x1140,
    AUDIT_SECURITY_CERTIFICATE_DATAMISMATCH = 0x1141,
    AUDIT_SECURITY_CERTIFICATE_EXPIRED = 0x1142,
    AUDIT_SECURITY_CERTIFICATE_INVALID = 0x1143,
    AUDIT_SECURITY_CERTIFICATE_UNTRUSTED = 0x1144,
    AUDIT_SECURITY_CERTIFICATE_REVOKED = 0x1145,
    AUDIT_SECURITY_CERTIFICATE_MISMATCH = 0x1146,
    AUDIT_NODE = 0x1200,
    AUDIT_NODE_ADD = 0x1210,
    AUDIT_NODE_DELETE = 0x1220,
    AUDIT_NODE_ADDREFERENCES = 0x1240,
    AUDIT_NODE_DELETEREFERENCES = 0x1280,
    AUDIT_UPDATE = 0x1400,
    AUDIT_UPDATE_WRITE = 0x1410,
    AUDIT_UPDATE_HISTORY = 0x1420,
    AUDIT_UPDATE_METHOD = 0x1440,
    AUDIT_CLIENT = 0x1800,
    AUDIT_CLIENT_UPDATEMETHOD = 0x1810,
};

pub const UserTokenType = enum(c_int) {
    ANONYMOUS = 0,
    USERNAME = 1,
    CERTIFICATE = 2,
    ISSUEDTOKEN = 3,
    _, // Allows for values up to the size of c_int (replaces FORCE32BIT)
};

pub const UserTokenPolicy = extern struct {
    policyId: String,
    tokenType: UserTokenType,
    issuedTokenType: String,
    issuerEndpointUrl: String,
    securityPolicyUri: String,
};

pub const ServerNotificationCallback = ?*const fn (
    server: *Server,
    type: ApplicationNotificationType,
    payload: KeyValueMap,
) callconv(.c) void;

pub const EndpointDescription = extern struct {
    endpointUrl: String,
    server: ApplicationDescription,
    serverCertificate: ByteString,
    securityMode: MessageSecurityMode,
    securityPolicyUri: String,
    userIdentityTokensSize: usize,
    userIdentityTokens: ?[*]UserTokenPolicy,
    transportProfileUri: String,
    securityLevel: u8,
};

pub const Duration = f64;

pub const GlobalNodeLifecycle = extern struct {
    /// Can be NULL. May replace the nodeContext
    constructor: ?*const fn (
        server: *Server,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        nodeId: *const NodeId,
        nodeContext: *?*anyopaque,
    ) callconv(.c) StatusCode,

    /// Can be NULL. The context cannot be replaced since the node is destroyed
    /// immediately afterwards anyway.
    destructor: ?*const fn (
        server: *Server,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        nodeId: *const NodeId,
        nodeContext: ?*anyopaque,
    ) callconv(.c) void,

    /// Can be NULL. Called during recursive node instantiation to define whether
    /// an optional child node should be created.
    createOptionalChild: ?*const fn (
        server: *Server,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        sourceNodeId: *const NodeId,
        targetParentNodeId: *const NodeId,
        referenceTypeId: *const NodeId,
    ) callconv(.c) bool,

    /// Can be NULL. Allows definition of the NodeId for the new node during
    /// recursive instantiation.
    generateChildNodeId: ?*const fn (
        server: *Server,
        sessionId: *const NodeId,
        sessionContext: ?*anyopaque,
        sourceNodeId: *const NodeId,
        targetParentNodeId: *const NodeId,
        referenceTypeId: *const NodeId,
        targetNodeId: *NodeId,
    ) callconv(.c) StatusCode,
};

pub const UInt32Range = extern struct {
    min: u32,
    max: u32,
};

pub const DurationRange = extern struct {
    min: Duration,
    max: Duration,
};

pub const ServerConfig = extern struct {
    context: ?*anyopaque,
    logging: ?*Logger,

    // Server Description
    buildInfo: BuildInfo,
    applicationDescription: ApplicationDescription,

    // Server Lifecycle
    shutdownDelay: f64,
    notifyLifecycleState: ?*const fn (server: ?*Server, state: LifecycleState) callconv(.c) void,

    // Rule Handling
    verifyRequestTimestamp: RuleHandling,
    allowEmptyVariables: RuleHandling,
    allowAllCertificateUris: RuleHandling,

    // Custom Data Types
    customDataTypes: ?*DataTypeArray,

    // EventLoop
    eventLoop: ?*EventLoop,
    externalEventLoop: bool,

    // Application Notification
    globalNotificationCallback: ServerNotificationCallback,
    lifecycleNotificationCallback: ServerNotificationCallback,
    secureChannelNotificationCallback: ServerNotificationCallback,
    sessionNotificationCallback: ServerNotificationCallback,
    serviceNotificationCallback: ServerNotificationCallback,
    subscriptionNotificationCallback: ServerNotificationCallback,
    auditNotificationCallback: ServerNotificationCallback,

    // Networking
    serverUrls: ?[*]String,
    serverUrlsSize: usize,

    // TCP transport settings
    tcpEnabled: bool,
    tcpBufSize: u32,
    tcpMaxMsgSize: u32,
    tcpMaxChunks: u32,
    tcpReuseAddr: bool,

    // Security and Encryption
    securityPoliciesSize: usize,
    securityPolicies: ?[*]SecurityPolicy,

    endpointsSize: usize,
    endpoints: ?[*]EndpointDescription,

    securityPolicyNoneDiscoveryOnly: bool,
    allowNonePolicyPassword: bool,

    secureChannelPKI: CertificateGroup,
    sessionPKI: CertificateGroup,

    // Plugins
    accessControl: AccessControl,
    nodestore: ?*Nodestore,
    nodeLifecycle: ?*GlobalNodeLifecycle,

    modellingRulesOnInstances: bool,

    // Limits
    maxSecureChannels: u16,
    maxSecurityTokenLifetime: u32,
    maxSessions: u16,
    maxSessionTimeout: f64,

    maxNodesPerRead: u32,
    maxNodesPerWrite: u32,
    maxNodesPerMethodCall: u32,
    maxNodesPerBrowse: u32,
    maxNodesPerRegisterNodes: u32,
    maxNodesPerTranslateBrowsePathsToNodeIds: u32,
    maxNodesPerNodeManagement: u32,
    maxMonitoredItemsPerCall: u32,
    maxReferencesPerNode: u32,

    reverseReconnectInterval: u32,

    // Async Operations
    asyncOperationTimeout: f64,
    maxAsyncOperationQueueSize: usize,
    asyncOperationCancelCallback: ?*const fn (server: ?*Server, out: ?*const anyopaque) callconv(.c) void,

    // Subscriptions
    subscriptionsEnabled: bool,
    maxSubscriptions: u32,
    maxSubscriptionsPerSession: u32,
    publishingIntervalLimits: DurationRange,
    lifeTimeCountLimits: UInt32Range,
    keepAliveCountLimits: UInt32Range,
    maxNotificationsPerPublish: u32,
    enableRetransmissionQueue: bool,
    maxRetransmissionQueueSize: u32,
    maxEventsPerNode: u32,

    maxMonitoredItems: u32,
    maxMonitoredItemsPerSubscription: u32,
    samplingIntervalLimits: DurationRange,
    queueSizeLimits: UInt32Range,
    maxPublishReqPerSession: u32,

    monitoredItemRegisterCallback: ?*const fn (
        server: ?*Server,
        sessionId: ?*const NodeId,
        sessionContext: ?*anyopaque,
        nodeId: ?*const NodeId,
        nodeContext: ?*anyopaque,
        attributeId: u32,
        removed: bool,
    ) callconv(.c) void,

    // Auditing
    auditingEnabled: bool,
    auditWriteUpdateEnabled: bool,
    auditMethodUpdateEnabled: bool,

    // Historical Access
    historizingEnabled: bool,
    historyDatabase: HistoryDatabase,
    accessHistoryDataCapability: bool,
    maxReturnDataValues: u32,
    accessHistoryEventsCapability: bool,
    maxReturnEventValues: u32,
    insertDataCapability: bool,
    insertEventCapability: bool,
    insertAnnotationsCapability: bool,
    replaceDataCapability: bool,
    replaceEventCapability: bool,
    updateDataCapability: bool,
    updateEventCapability: bool,
    deleteRawCapability: bool,
    deleteEventCapability: bool,
    deleteAtTimeDataCapability: bool,

    // Encryption Password Callback
    privateKeyPasswordCallback: ?*const fn (
        sc: ?*ServerConfig,
        password: ?*ByteString,
    ) callconv(.c) StatusCode,
};

pub extern fn UA_ServerConfig_clear(config: ?*ServerConfig) callconv(.c) void;

pub inline fn UA_ServerConfig_clean(config: ?*ServerConfig) void {
    UA_ServerConfig_clear(config);
}

pub extern fn serverCustomTypes(
    server: ?*Server,
) callconv(.c) ?*const DataTypeArray;

pub fn ListHead(comptime T: type) type {
    return extern struct {
        lh_first: ?*T,
    };
}

pub fn SimpleQHead(comptime T: type) type {
    return extern struct {
        sqh_first: ?*T,
        sqh_last: ?*?*T,
    };
}

pub fn TailQHead(comptime T: type) type {
    return extern struct {
        tqh_first: ?*T,
        tqh_last: ?*?*T,
    };
}

pub fn SimpleQEntry(comptime T: type) type {
    return extern struct {
        sqe_next: ?*T,
    };
}

pub fn ListEntry(comptime T: type) type {
    return extern struct {
        le_next: ?*T,
        le_prev: ?*?*T,
    };
}

pub fn TailQEntry(comptime T: type) type {
    return extern struct {
        tqe_next: ?*T,
        tqe_prev: ?*?*T,
    };
}

pub extern "open62541" fn UA_Server_new() callconv(.c) Server;
pub extern "open62541" fn UA_Server_delete(server: *Server) callconv(.c) StatusCode;
pub extern "open62541" fn UA_Server_runUntilInterrupt(server: *Server) callconv(.c) StatusCode;

pub extern "open62541" fn UA_StatusCode_isBad(code: StatusCode) bool;
pub extern "open62541" fn UA_StatusCode_isUncertain(code: StatusCode) bool;
pub extern "open62541" fn UA_StatusCode_isGood(code: StatusCode) bool;
pub extern "open62541" fn UA_StatusCode_name(code: StatusCode) [*:0]const u8;
