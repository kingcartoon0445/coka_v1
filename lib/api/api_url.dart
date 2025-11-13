var apiBaseUrl = 'https://dev.coka.ai/';
const apiAutomationUrl = 'https://automation.coka.ai';
const apiCallCenterUrl = 'https://callcenter.coka.ai';

//================ COKA ======================
//auth
const socialLoginApi = '/api/v1/auth/social/login';
const phoneLoginApi = '/api/v1/auth/login';
const verifyOtpApi = '/api/v1/otp/verify';
const resendOtpApi = '/api/v1/otp/resend';
const refreshTokenApi = '/api/v1/account/refreshtoken';

//profile
const getProfileListApi = '/api/v1/user/profile/getlistpaging';
const getProfileDetailApi = '/api/v1/user/profile/getdetail/';
const postProfileCreateApi = '/api/v1/user/profile/create';
const patchProfileUpdateApi = '/api/v1/user/profile/update';
const postProfileSwitchApi = '/api/v1/user/profile/switch';
const putProfileUpdateAvatarApi = '/api/v1/user/profile/updateavatar';
const putProfileUpdateCoverApi = '/api/v1/user/profile/updatecover';
const updateFcmTokenApi = '/api/v1/user/fcm';

//Organization
String getOrganizationDetailApiV2(String organizationId) =>
    '${apiBaseUrl}api/v1/organization/$organizationId';
String getOrganizationQrCodeApi(String organizationId) =>
    '${apiBaseUrl}api/v2/organization/$organizationId/qrcode';
const getOrganizationListApi = '/api/v1/organization/getlistpaging';
const getOrganizationDetailApi = '/api/v1/organization/getdetail/';
const postOrganizationCreateApi = '/api/v1/organization/create';
const patchOrganizationUpdateApi = '/api/v1/organization/update/';
const deleteOrganizationApi = '/api/v1/organization/delete/';
const leaveOrganizationApi = '/api/v1/organization/leave';

//fb
const fbConnectApi = '/api/v1/auth/facebook/connect';
const fbGetListConversationApi = '/api/v1/social/conversation/getlistpaging';
const fbGetDetailConversationApi = '/api/v1/social/message/getlistpaging';
const fbSendMessageApi = '/api/v1/social/message/sendmessage';
const setGptPageStatusApi = '/api/v1/social/hub/setupgpt/';
const updateReadStatusApi = '/api/v1/social/conversation/read/';

//hub
const getListHubPagingApi = '/api/v1/social/hub/getlistpaging';
const getHubDetailApi = '/api/v1/social/hub/getdetail/';
const updateHubStatusApi = '/api/v1/social/hub/updatestatus/';
const updateHubFeedMessApi = '/api/v1/social/hub/updatesubscribed/';

//Website
const getWebsiteListApi = '/api/v1/integration/website/getlistpaging';
const addWebsiteApi = '/api/v1/integration/website/create';
const deleteWebsiteApi = '/api/v1/integration/website/delete/';
const verifyWebsiteApi = '/api/v1/integration/website/verify/';
const updateStatusWebsiteApi = '/api/v1/integration/website/updatestatus/';

//Workspace
const getWorkspaceListApi = '/api/v1/organization/workspace/getlistpaging';
const createWorkspaceApi = '/api/v1/organization/workspace/create';
const getWorkspaceDetailApi = '/api/v1/organization/workspace/getdetail/';
const updateWorkspaceApi = '/api/v1/organization/workspace/update/';
const deleteWorkspaceApi = '/api/v1/organization/workspace/delete/';
const leaveWorkspaceApi = '/api/v1/organization/workspace/leave';
const getWorkspaceMemberListApi =
    "/api/v1/organization/workspace/user/getlistpaging";
const postWorkspaceGrantRoleApi = "/api/v1/organization/workspace/grantrole";
const addMemberToWorkspaceApi = "/api/v1/organization/workspace/user";
const updateAutomationWorkspaceApi =
    "/api/v1/organization/workspace/updateautomation/";

//conversation
const getRoomListApi = '/api/v1/omni/conversation/getlistpaging';
const setReadApi = '/api/v1/integration/omni/conversation/read/';
const syncConvApi = '/api/v1/omni/conversation/resync';
const getConvListApi = '/api/v1/social/message/getlistpaging';
const sendConvApi = '/api/v1/social/message/sendmessage';

//customer
const getCustomerListApi = '/api/v1/crm/contact/getlistpaging';
const getDetailCustomerApi = '/api/v1/crm/contact/getdetail/';
const createCustomerApi = '/api/v1/crm/contact/create';
const importCustomerApi = '/api/v1/crm/contact/import';
const updateCustomerApi = '/api/v1/crm/';
const phoneCheckApi = "/api/v1/crm/contact/check";
const getTagListApi = "/api/v1/crm/category/tags/getlistpaging";
const getSourceListApi = "/api/v1/crm/category/source/getlistpaging";
//Journey
const journeyApi = '/api/v1/crm/contact/';

//Tổ chức - Gửi lời mời
const postOrgInviteApi = "/api/v1/organization/member/invite";
const getOrgInviteListApi = "/api/v1/organization/member/invite/getlistpaging";
const postOrgAcceptInviteApi = "/api/v1/organization/member/invite/accept";
const postOrgRefuseInviteApi = "/api/v1/organization/member/cancel/";
const getOrgSearchProfileApi = "/api/v1/organization/member/searchprofile";

//Tổ chức - thành viên xin gia nhập
const postOrgRequestApi = "/api/v1/organization/member/request/requestinvite";
const getOrgRequestListApi =
    "/api/v1/organization/member/request/getlistpaging";
const postOrgAcceptRequestApi = "/api/v1/organization/member/request/accept";
const postOrgCancelRequestApi = "/api/v1/organization/member/request/cancel/";
const getSearchOrgApi =
    "/api/v1/organization/member/request/searchorganization";

// Org - Member
const getOrgMemberListApi = "/api/v1/organization/member/getlistpaging";
const postOrgRoleMemberApi = "/api/v1/organization/member/grantrole";
const deleteOrgMemberApi = "/api/v1/organization/member/";

//CRM-> Team
const teamApi = "/api/v1/crm/team";

//Dashboard
const getDashboardSummaryApi = "/api/v1/workspace/report/summary";
const getDashboardOverTime = "/api/v1/crm/report/getstatisticsovertime";
const getDashboardByStage = "/api/v1/crm/report/getstatisticsbystage";
const getDashboardByRating = "/api/v1/crm/report/getstatisticsbyrating";
const getDashboardByDataSource = "/api/v1/crm/report/getstatisticsbydatasource";
const getDashboardByUtmSource = "/api/v1/crm/report/getstatisticsbyutmsource";
const getDashboardByTag = "/api/v1/crm/report/getstatisticsbytag";
const getDashboardByUser = "/api/v1/crm/report/getstatisticsbyuser";
const statisticsByStageGroup = "/api/v1/crm/report/getstatisticsbystagegroup";

//Notification
const getNotificationListApi = "/api/v1/notify/getlistpaging";
const updateNotificationReadApi = "/api/v1/notify/updatestatus/notifyid";
const getNotificationListUnreadApi = "/api/v1/notify/countunread";
//================ Automation ======================
const createChatApi = "/api/chat/create";
