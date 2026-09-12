import '/core/base_model.dart';
import '/widgets/user_info/user_info_model.dart';
import 'auth_user_info_widget.dart' show AuthUserInfoWidget;

class AuthUserInfoModel extends BaseModel<AuthUserInfoWidget> {
  late UserInfoModel userInfoModel;

  @override
  void initState(context) {
    userInfoModel = UserInfoModel();
    userInfoModel.init(context);
  }

  @override
  void dispose() {
    userInfoModel.dispose();
    super.dispose();
  }
}
