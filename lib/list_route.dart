import 'package:coka/screen/authentication/login_screen/login_screen.dart';
import 'package:coka/screen/authentication/password_screen/otp_reset_pass/otp_reset_pass_screen.dart';
import 'package:coka/screen/authentication/password_screen/reset_pass_screen.dart';
import 'package:coka/screen/authentication/register_screen/org_page.dart';
import 'package:coka/screen/authentication/register_screen/profile_page.dart';
import 'package:coka/screen/crm_automation/crm_auto_binding.dart';
import 'package:coka/screen/crm_automation/crm_auto_page.dart';
import 'package:coka/screen/crm_conversation/contact_detail/contact_detail_binding.dart';
import 'package:coka/screen/crm_conversation/contact_detail/contact_detail_page.dart';
import 'package:coka/screen/crm_conversation/crm_conversation_binding.dart';
import 'package:coka/screen/crm_conversation/crm_conversation_page.dart';
import 'package:coka/screen/crm_customer/crm_customer_binding.dart';
import 'package:coka/screen/crm_customer/crm_customer_page.dart';
import 'package:coka/screen/crm_omnichannel/crm_omnichannel_binding.dart';
import 'package:coka/screen/crm_omnichannel/crm_omnichannel_page.dart';
import 'package:coka/screen/main/main_binding.dart';
import 'package:coka/screen/main/main_page.dart';
import 'package:coka/screen/messages/messages_binding.dart';
import 'package:coka/screen/messages/messages_page.dart';
import 'package:coka/screen/splash_screen.dart';
import 'package:coka/screen/workspace/getx/chat_channel_binding.dart';
import 'package:coka/screen/workspace/main_binding.dart';
import 'package:coka/screen/workspace/main_page.dart';
import 'package:coka/screen/workspace/pages/chat_channel.dart';
import 'package:get/get.dart';

List<GetPage> listRoute = [
  GetPage(name: '/login', page: () => const LoginScreen()),
  GetPage(
      name: '/register',
      page: () => const RegisterProfilePage(
            isUpdateProfile: false,
          )),
  GetPage(
      name: '/updateProfile',
      page: () => const RegisterProfilePage(
            isUpdateProfile: true,
          )),
  GetPage(
      name: '/createPOrg',
      page: () => const RegisterOrgPage(
            isPersonal: true,
          )),
  GetPage(name: '/signUp', page: () => const LoginScreen()),
  GetPage(name: '/resetPass', page: () => const ResetPassScreen()),
  GetPage(name: '/otpResetPass', page: () => const OtpResetPassScreen()),
  GetPage(name: '/splash', page: () => const SplashScreen()),
  GetPage(
      name: '/crmConversation',
      page: () => const CrmConversationPage(),
      binding: CrmConversationBinding()),
  GetPage(name: "/messages", page: () => const MessagesPage(), binding: MessagesBinding()),
  GetPage(
      name: '/contactDetail',
      page: () => const ContactDetailPage(),
      binding: ContactDetailBinding()),
  GetPage(name: '/crmCustomer', page: () => const CrmCustomerPage(), binding: CrmCustomerBinding()),
  GetPage(
      name: '/crmOmnichannel',
      page: () => const CrmOmnichannelPage(),
      binding: CrmOmnichannelBinding()),
  GetPage(name: '/crmAuto', page: () => const CrmAutoPage(), binding: CrmAutoBinding()),
  GetPage(name: '/chat', page: () => const ChatChannelPage(), binding: ChatChannelBinding()),
  GetPage(name: '/main', page: () => const MainPage(), binding: MainBinding()),
  GetPage(
      name: '/workspaceMain',
      page: () => const WorkspaceMainPage(),
      binding: WorkspaceMainBinding()),
];
