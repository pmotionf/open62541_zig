#ifndef OPC_TYPES_HELPER_H_
#define OPC_TYPES_HELPER_H_

#include "open62541.h"

// --- UA_DataType Accessors ---
const UA_DataType* UA_DataType_get(size_t type_index);
const char*        UA_DataType_get_name(const UA_DataType *type);
const UA_NodeId*   UA_DataType_get_typeId(const UA_DataType *type);

// Bitfield Accessors
uint16_t UA_DataType_get_memSize(const UA_DataType *type);
uint8_t  UA_DataType_get_typeKind(const UA_DataType *type);
bool     UA_DataType_get_pointerFree(const UA_DataType *type);
bool     UA_DataType_get_overlayable(const UA_DataType *type);
uint8_t  UA_DataType_get_membersSize(const UA_DataType *type);

// The Critical Member Pointer Accessor
UA_DataTypeMember* UA_DataType_get_members(const UA_DataType *type);

// --- UA_DataTypeMember Accessors ---
const char*        UA_DataTypeMember_get_name(const UA_DataTypeMember *member);
const UA_DataType* UA_DataTypeMember_get_type(const UA_DataTypeMember *member);
uint8_t            UA_DataTypeMember_get_padding(const UA_DataTypeMember *member);
bool               UA_DataTypeMember_get_isArray(const UA_DataTypeMember *member);
bool               UA_DataTypeMember_get_isOptional(const UA_DataTypeMember *member);

// --- UA_DiagnosticInfo Accessors ---
bool UA_DiagnosticInfo_hasSymbolicId(const UA_DiagnosticInfo *info);
bool UA_DiagnosticInfo_hasNamespaceUri(const UA_DiagnosticInfo *info);
bool UA_DiagnosticInfo_hasLocalizedText(const UA_DiagnosticInfo *info);
bool UA_DiagnosticInfo_hasLocale(const UA_DiagnosticInfo *info);
bool UA_DiagnosticInfo_hasAdditionalInfo(const UA_DiagnosticInfo *info);
bool UA_DiagnosticInfo_hasInnerStatusCode(const UA_DiagnosticInfo *info);
bool UA_DiagnosticInfo_hasInnerDiagnosticInfo(const UA_DiagnosticInfo *info);
UA_Int32 UA_DiagnosticInfo_getSymbolicId(const UA_DiagnosticInfo *info);
UA_Int32 UA_DiagnosticInfo_getNamespaceUri(const UA_DiagnosticInfo *info);
UA_Int32 UA_DiagnosticInfo_getLocalizedText(const UA_DiagnosticInfo *info);
UA_Int32 UA_DiagnosticInfo_getLocale(const UA_DiagnosticInfo *info);
const UA_String* UA_DiagnosticInfo_getAdditionalInfo(const UA_DiagnosticInfo *info);
UA_StatusCode UA_DiagnosticInfo_getInnerStatusCode(const UA_DiagnosticInfo *info);
const struct UA_DiagnosticInfo* UA_DiagnosticInfo_getInnerDiagnosticInfo(const UA_DiagnosticInfo *info);

// --- UA_BrowseResponse Accessors ---
const UA_ResponseHeader* UA_BrowseResponse_getHeader(const UA_BrowseResponse *response);
size_t UA_BrowseResponse_getResultsSize(const UA_BrowseResponse *response);
const UA_BrowseResult* UA_BrowseResponse_getResults(const UA_BrowseResponse *response);
size_t UA_BrowseResponse_getDiagnosticInfosSize(const UA_BrowseResponse *response);
const UA_DiagnosticInfo* UA_BrowseResponse_getDiagnosticInfos(const UA_BrowseResponse *response);
UA_BrowseResponse* UA_Client_Service_browse_ptr(UA_Client *client, const UA_BrowseRequest req);
void UA_BrowseResponse_delete_wrapper(UA_BrowseResponse *p);

// --- UA_ResponseHeader Accessors ---
UA_DateTime UA_ResponseHeader_getTimestamp(const UA_ResponseHeader *header);
UA_UInt32 UA_ResponseHeader_getRequestHandle(const UA_ResponseHeader *header);
UA_StatusCode UA_ResponseHeader_getServiceResult(const UA_ResponseHeader *header);
const UA_DiagnosticInfo* UA_ResponseHeader_getServiceDiagnostics(const UA_ResponseHeader *header);
size_t UA_ResponseHeader_getStringTableSize(const UA_ResponseHeader *header);
const UA_String* UA_ResponseHeader_getStringTable(const UA_ResponseHeader *header);
const UA_ExtensionObject* UA_ResponseHeader_getAdditionalHeader(const UA_ResponseHeader *header);
#endif
