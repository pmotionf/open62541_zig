#include "OPC_types_helper.h"
#include "open62541.h"

const UA_DataType* UA_DataType_get(size_t type_index) {
    return &UA_TYPES[type_index];
}

const char* UA_DataType_get_name(const UA_DataType *type) {
#ifdef UA_ENABLE_TYPEDESCRIPTION
    return type->typeName;
#else
    return NULL;
#endif
}

const UA_NodeId* UA_DataType_get_typeId(const UA_DataType *type) {
    return &type->typeId;
}

uint16_t UA_DataType_get_memSize(const UA_DataType *type) {
    return (uint16_t)type->memSize;
}

uint8_t  UA_DataType_get_typeKind(const UA_DataType *type) {
    return (uint8_t)type->typeKind;
}

bool     UA_DataType_get_pointerFree(const UA_DataType *type) {
    return (bool)type->pointerFree;
}

bool     UA_DataType_get_overlayable(const UA_DataType *type) {
    return (bool)type->overlayable;
}

uint8_t  UA_DataType_get_membersSize(const UA_DataType *type) {
    return (uint8_t)type->membersSize;
}

UA_DataTypeMember* UA_DataType_get_members(const UA_DataType *type) {
    return type->members;
}

// Member Accessors
const char* UA_DataTypeMember_get_name(const UA_DataTypeMember *member) {
#ifdef UA_ENABLE_TYPEDESCRIPTION
    return member->memberName;
#else
    return NULL;
#endif
}

const UA_DataType* UA_DataTypeMember_get_type(const UA_DataTypeMember *member) {
    return member->memberType;
}

uint8_t UA_DataTypeMember_get_padding(const UA_DataTypeMember *member) { return (uint8_t)member->padding; }
bool    UA_DataTypeMember_get_isArray(const UA_DataTypeMember *member) { return (bool)member->isArray; }
bool    UA_DataTypeMember_get_isOptional(const UA_DataTypeMember *member) { return (bool)member->isOptional; }

// --- UA_DiagnosticInfo Accessors ---
/* Flag Implementations */
bool UA_DiagnosticInfo_hasSymbolicId(const UA_DiagnosticInfo *info) { return info->hasSymbolicId; }
bool UA_DiagnosticInfo_hasNamespaceUri(const UA_DiagnosticInfo *info) { return info->hasNamespaceUri; }
bool UA_DiagnosticInfo_hasLocalizedText(const UA_DiagnosticInfo *info) { return info->hasLocalizedText; }
bool UA_DiagnosticInfo_hasLocale(const UA_DiagnosticInfo *info) { return info->hasLocale; }
bool UA_DiagnosticInfo_hasAdditionalInfo(const UA_DiagnosticInfo *info) { return info->hasAdditionalInfo; }
bool UA_DiagnosticInfo_hasInnerStatusCode(const UA_DiagnosticInfo *info) { return info->hasInnerStatusCode; }
bool UA_DiagnosticInfo_hasInnerDiagnosticInfo(const UA_DiagnosticInfo *info) { return info->hasInnerDiagnosticInfo; }

/* Data Implementations */
UA_Int32 UA_DiagnosticInfo_getSymbolicId(const UA_DiagnosticInfo *info) { return info->symbolicId; }
UA_Int32 UA_DiagnosticInfo_getNamespaceUri(const UA_DiagnosticInfo *info) { return info->namespaceUri; }
UA_Int32 UA_DiagnosticInfo_getLocalizedText(const UA_DiagnosticInfo *info) { return info->localizedText; }
UA_Int32 UA_DiagnosticInfo_getLocale(const UA_DiagnosticInfo *info) { return info->locale; }

const UA_String* UA_DiagnosticInfo_getAdditionalInfo(const UA_DiagnosticInfo *info) {
    return &info->additionalInfo;
}

UA_StatusCode UA_DiagnosticInfo_getInnerStatusCode(const UA_DiagnosticInfo *info) {
    return info->innerStatusCode;
}

const struct UA_DiagnosticInfo* UA_DiagnosticInfo_getInnerDiagnosticInfo(const UA_DiagnosticInfo *info) {
    return info->innerDiagnosticInfo;
}

// --- UA_BrowseResponse Accessors ---
const UA_ResponseHeader* UA_BrowseResponse_getHeader(const UA_BrowseResponse *response) {
    return &response->responseHeader;
}

size_t UA_BrowseResponse_getResultsSize(const UA_BrowseResponse *response) {
    return response->resultsSize;
}

const UA_BrowseResult* UA_BrowseResponse_getResults(const UA_BrowseResponse *response) {
    return response->results;
}

size_t UA_BrowseResponse_getDiagnosticInfosSize(const UA_BrowseResponse *response) {
    return response->diagnosticInfosSize;
}

const UA_DiagnosticInfo* UA_BrowseResponse_getDiagnosticInfos(const UA_BrowseResponse *response) {
    return response->diagnosticInfos;
}

UA_BrowseResponse* UA_Client_Service_browse_ptr(UA_Client *client, const UA_BrowseRequest req) {
    UA_BrowseResponse *res = UA_BrowseResponse_new();
    *res = UA_Client_Service_browse(client, req);
    return res;
}
void UA_BrowseResponse_delete_wrapper(UA_BrowseResponse *p) {
    UA_BrowseResponse_delete(p);
}

UA_DateTime UA_ResponseHeader_getTimestamp(const UA_ResponseHeader *header) {
    return header->timestamp;
}

UA_UInt32 UA_ResponseHeader_getRequestHandle(const UA_ResponseHeader *header) {
    return header->requestHandle;
}

UA_StatusCode UA_ResponseHeader_getServiceResult(const UA_ResponseHeader *header) {
    return header->serviceResult;
}

const UA_DiagnosticInfo* UA_ResponseHeader_getServiceDiagnostics(const UA_ResponseHeader *header) {
    return &header->serviceDiagnostics;
}

size_t UA_ResponseHeader_getStringTableSize(const UA_ResponseHeader *header) {
    return header->stringTableSize;
}

const UA_String* UA_ResponseHeader_getStringTable(const UA_ResponseHeader *header) {
    return header->stringTable;
}

const UA_ExtensionObject* UA_ResponseHeader_getAdditionalHeader(const UA_ResponseHeader *header) {
    return &header->additionalHeader;
}
