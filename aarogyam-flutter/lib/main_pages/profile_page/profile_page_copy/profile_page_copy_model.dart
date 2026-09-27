import '/flutter_flow/flutter_flow_util.dart';
import '/widgets/user_info/user_info_widget.dart';
import 'profile_page_copy_widget.dart' show ProfilePageCopyWidget;

class ProfilePageCopyModel extends BaseModel<ProfilePageCopyWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for UserInfo component.
  late UserInfoModel userInfoModel;  @override
  void initState(BuildContext context) {
    userInfoModel = createModel(context, () => UserInfoModel());

    debugLogWidgetClass(this);
  }

  @override
  void dispose() {
    userInfoModel.dispose();
    super.dispose();
  }

  @override
  WidgetClassDebugData toWidgetClassDebugData() =>
      const WidgetClassDebugData();
}
