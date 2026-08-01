library kazi_core;

//TODO: Remove these exports when create abstraction
export 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:go_router/go_router.dart';
export 'package:intl/intl.dart';
export 'package:riverpod/riverpod.dart';
export 'package:riverpod_annotation/riverpod_annotation.dart';

// Re-exporting Riverpod centralizes the dependency for the consuming apps.
// riverpod_annotation surfaces internal `$`-prefixed elements that generated
// code relies on, so we opt out of the internal-export warning here.
// ignore_for_file: invalid_export_of_internal_element

export 'kazi_providers.dart';
//Auth Module
export 'modules/auth/application/use_cases/sign_up_use_case.dart';
export 'modules/auth/domain/repositories/auth_repository.dart';
//Currency Module
export 'modules/currency/application/currency_converter.dart';
export 'modules/currency/data/mocks/exchange_rate_mock.dart';
export 'modules/currency/domain/models/exchange_rates.dart';
export 'modules/currency/domain/repositories/exchange_rate_repository.dart';
//Services Module
export 'modules/services/domain/repositories/service_type_repository.dart';
//Users Module
export 'modules/users/domain/models/create_user_params.dart';
export 'modules/users/domain/models/get_users_params.dart';
export 'modules/users/domain/models/sign_up_params.dart';
export 'modules/users/domain/models/update_user_params.dart';
export 'modules/users/domain/repositories/user_repository.dart';
export 'shared/components/bottom_sheet/kazi_bottom_sheet.dart';
export 'shared/components/buttons/kazi_circular_button.dart';
export 'shared/components/buttons/kazi_elevated_button.dart';
export 'shared/components/buttons/kazi_pill_button.dart';
export 'shared/components/buttons/kazi_text_button.dart';
//Shared - Components
export 'shared/components/calendar/kazi_calendar.dart';
export 'shared/components/calendar/models/calendar_models.dart';
export 'shared/components/dialog/kazi_dialog.dart';
export 'shared/components/form/kazi_date_picker.dart';
export 'shared/components/form/kazi_date_range_picker.dart';
export 'shared/components/form/kazi_dropdown.dart';
export 'shared/components/form/kazi_field_label.dart';
export 'shared/components/form/kazi_image_picker.dart';
export 'shared/components/form/kazi_text_form_field.dart';
export 'shared/components/form/models/dropdown_item.dart';
export 'shared/components/images/kazi_image.dart';
export 'shared/components/images/kazi_svg.dart';
export 'shared/components/kazi_app_bar.dart';
export 'shared/components/kazi_page_title.dart';
export 'shared/components/safe_area/kazi_padding_wrap.dart';
export 'shared/components/safe_area/kazi_safe_area.dart';
export 'shared/components/safe_area/kazi_scroll_behavior.dart';
export 'shared/components/snack_bar/kazi_snackbar.dart';
export 'shared/components/status/kazi_error.dart';
export 'shared/components/status/kazi_loading.dart';
export 'shared/components/status/kazi_no_data.dart';
export 'shared/components/webview/kazi_webview.dart';
//Shared - Currency
export 'shared/currency/kazi_currency_controller.dart';
export 'shared/currency/kazi_currency_manager.dart';
export 'shared/currency/supported_currency.dart';
//Shared - Entities
export 'shared/entities/address.dart';
export 'shared/entities/client_info.dart';
export 'shared/entities/service.dart';
export 'shared/entities/service_type.dart';
export 'shared/entities/services_filter.dart';
export 'shared/entities/user.dart';
//Shared - Enumns
export 'shared/enums/fast_search.dart';
export 'shared/enums/order_by.dart';
export 'shared/enums/user_type.dart';
export 'shared/environment/flavor.dart';
//Shared - Others
export 'shared/extensions/extensions.dart';
export 'shared/l10n/generated/l10n.dart';
export 'shared/localization/kazi_locale_controller.dart';
export 'shared/localization/kazi_locale_manager.dart';
export 'shared/localization/kazi_locale_policy.dart';
//Shared - Models
export 'shared/models/errors.dart';
export 'shared/navigation/kazi_auth.dart';
export 'shared/navigation/kazi_navigation_arguments.dart';
export 'shared/navigation/kazi_navigation_transition.dart';
export 'shared/navigation/kazi_navigator.dart';
export 'shared/navigation/kazi_page.dart';
export 'shared/navigation/kazi_router.dart';
//Shared - Services
export 'shared/services/app_info/kazi_app_info_service.dart';
export 'shared/services/local_storage/kazi_local_storage_service.dart';
export 'shared/services/url_launcher/kazi_url_launcher_service.dart';
export 'shared/themes/themes.dart';
export 'shared/utils/form_validator.dart';
export 'shared/utils/log_utils.dart';
export 'shared/utils/number_format_utils.dart';
