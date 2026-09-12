import '/core/base_model.dart';
import 'home_page_widget.dart' show HomePageWidget;
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class HomePageModel extends BaseModel<HomePageWidget> {
  late CardSwiperController swipeableStackController;

  @override
  void initState(context) {
    swipeableStackController = CardSwiperController();
  }

  @override
  void dispose() {
    swipeableStackController.dispose();
    super.dispose();
  }
}
