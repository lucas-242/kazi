// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'es';

  static String m0(property) => "${property} ya existe";

  static String m1(url) => "No fue posible abrir la URL ${url}";

  static String m2(start, end) => "Filtrando desde ${start} hasta ${end}";

  static String m3(start, end) => "Desde ${start} hasta ${end}";

  static String m4(person) => "¡Hola, ${person}!";

  static String m5(property) => "${property} está en uso";

  static String m6(property) => "${property} inválido";

  static String m7(property) => "${property} está vacío";

  static String m8(property) => "${property} debe ser completado";

  static String m9(item) => "¿Deseas eliminar ${item}?";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "actions": MessageLookupByLibrary.simpleMessage("Acciones"),
    "add": MessageLookupByLibrary.simpleMessage("Agregar"),
    "address": MessageLookupByLibrary.simpleMessage("Dirección"),
    "all": MessageLookupByLibrary.simpleMessage("Todos"),
    "alreadyExists": m0,
    "alreadyHasAccont": MessageLookupByLibrary.simpleMessage(
      "¿Ya tienes una cuenta? ",
    ),
    "appSubtitle": MessageLookupByLibrary.simpleMessage(
      "Organiza tus servicios",
    ),
    "applyFilters": MessageLookupByLibrary.simpleMessage("Aplicar filtros"),
    "back": MessageLookupByLibrary.simpleMessage("Volver"),
    "calculator": MessageLookupByLibrary.simpleMessage("Calculadora"),
    "calendar": MessageLookupByLibrary.simpleMessage("Calendario"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
    "changePassword": MessageLookupByLibrary.simpleMessage(
      "Cambiar contraseña",
    ),
    "clients": MessageLookupByLibrary.simpleMessage("Clientes"),
    "clipperCut": MessageLookupByLibrary.simpleMessage("Corte con máquina"),
    "close": MessageLookupByLibrary.simpleMessage("Cerrar"),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirmar"),
    "confirmAction": MessageLookupByLibrary.simpleMessage("Confirmar acción"),
    "confirmPassword": MessageLookupByLibrary.simpleMessage(
      "Confirmar contraseña",
    ),
    "contact": MessageLookupByLibrary.simpleMessage("Contacto"),
    "contactEmail": MessageLookupByLibrary.simpleMessage(
      "guimaraeslucas242@gmail.com",
    ),
    "continueAction": MessageLookupByLibrary.simpleMessage("Continuar"),
    "create": MessageLookupByLibrary.simpleMessage("Crear"),
    "createAccount": MessageLookupByLibrary.simpleMessage("Crear una cuenta"),
    "currentPassword": MessageLookupByLibrary.simpleMessage(
      "Contraseña actual",
    ),
    "darkMode": MessageLookupByLibrary.simpleMessage("Modo oscuro"),
    "date": MessageLookupByLibrary.simpleMessage("Fecha"),
    "defaultValue": MessageLookupByLibrary.simpleMessage(
      "Valor predeterminado",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Eliminar"),
    "description": MessageLookupByLibrary.simpleMessage("Descripción"),
    "details": MessageLookupByLibrary.simpleMessage("Detalles"),
    "didntReceiveAnything": MessageLookupByLibrary.simpleMessage(
      "¿No recibiste nada? ",
    ),
    "discount": MessageLookupByLibrary.simpleMessage("Descuento"),
    "discountPercentage": MessageLookupByLibrary.simpleMessage(
      "Porcentaje de descuento",
    ),
    "discounts": MessageLookupByLibrary.simpleMessage("Descuentos"),
    "doesntHaveAccount": MessageLookupByLibrary.simpleMessage(
      "¿No tienes una cuenta? ",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("Editar"),
    "editService": MessageLookupByLibrary.simpleMessage("Editar servicio"),
    "editServiceType": MessageLookupByLibrary.simpleMessage("Editar tipo"),
    "email": MessageLookupByLibrary.simpleMessage("Correo electrónico"),
    "employee": MessageLookupByLibrary.simpleMessage("Colaborador"),
    "employees": MessageLookupByLibrary.simpleMessage("Colaboradores"),
    "errorAccessDenied": MessageLookupByLibrary.simpleMessage(
      "Acceso denegado",
    ),
    "errorCantDeleteServiceType": MessageLookupByLibrary.simpleMessage(
      "El tipo de servicio no puede eliminarse porque está en uso",
    ),
    "errorCredentialIsInvalid": MessageLookupByLibrary.simpleMessage(
      "La credencial es inválida",
    ),
    "errorEmailIsInvalid": MessageLookupByLibrary.simpleMessage(
      "El correo electrónico es inválido o está mal formateado",
    ),
    "errorEmailWasNotFound": MessageLookupByLibrary.simpleMessage(
      "El correo electrónico no fue encontrado, por favor crea una cuenta",
    ),
    "errorIncorrectEmailOrPassword": MessageLookupByLibrary.simpleMessage(
      "Correo electrónico o contraseña incorrectos",
    ),
    "errorLaunchUrl": m1,
    "errorMethodNotAllowed": MessageLookupByLibrary.simpleMessage(
      "Método no permitido. Intenta con otra cuenta o contacta al soporte.",
    ),
    "errorNotFound": MessageLookupByLibrary.simpleMessage(
      "Dirección no encontrada.",
    ),
    "errorThereIsAnotherAccount": MessageLookupByLibrary.simpleMessage(
      "Ya existe una cuenta con estas credenciales",
    ),
    "errorTimeout": MessageLookupByLibrary.simpleMessage(
      "El servidor tardó en responder. Inténtalo nuevamente más tarde o contáctanos.",
    ),
    "errorToAddService": MessageLookupByLibrary.simpleMessage(
      "Error al agregar el servicio.",
    ),
    "errorToAddServiceType": MessageLookupByLibrary.simpleMessage(
      "Error al agregar el tipo de servicio.",
    ),
    "errorToCountServices": MessageLookupByLibrary.simpleMessage(
      "Error al obtener la cantidad de servicios.",
    ),
    "errorToDeleteService": MessageLookupByLibrary.simpleMessage(
      "Error al eliminar el servicio.",
    ),
    "errorToDeleteServiceType": MessageLookupByLibrary.simpleMessage(
      "Error al eliminar el tipo de servicio.",
    ),
    "errorToGetServiceTypes": MessageLookupByLibrary.simpleMessage(
      "Error al obtener los tipos de servicio.",
    ),
    "errorToGetServices": MessageLookupByLibrary.simpleMessage(
      "Error al obtener los servicios.",
    ),
    "errorToResetPassword": MessageLookupByLibrary.simpleMessage(
      "Error al restablecer la contraseña.",
    ),
    "errorToSendEmail": MessageLookupByLibrary.simpleMessage(
      "Error al enviar el correo.",
    ),
    "errorToSignIn": MessageLookupByLibrary.simpleMessage(
      "Error al iniciar sesión. Inténtalo más tarde o contacta al soporte.",
    ),
    "errorToSignUp": MessageLookupByLibrary.simpleMessage(
      "Error al registrarse. Inténtalo más tarde o contacta al soporte.",
    ),
    "errorToUpdateService": MessageLookupByLibrary.simpleMessage(
      "Error al editar el servicio.",
    ),
    "errorToUpdateServiceType": MessageLookupByLibrary.simpleMessage(
      "Error al editar el tipo de servicio.",
    ),
    "errorUnknowError": MessageLookupByLibrary.simpleMessage(
      "Ocurrió un error desconocido.",
    ),
    "errorUserHasBeenDisabled": MessageLookupByLibrary.simpleMessage(
      "Este usuario ha sido deshabilitado. Contacta al soporte para obtener ayuda",
    ),
    "errorVerificationCodeIsInvalid": MessageLookupByLibrary.simpleMessage(
      "El código de verificación ingresado es inválido",
    ),
    "errorVerificationIdIsInvalid": MessageLookupByLibrary.simpleMessage(
      "El ID de verificación ingresado es inválido",
    ),
    "exit": MessageLookupByLibrary.simpleMessage("Salir"),
    "field": MessageLookupByLibrary.simpleMessage("Campo"),
    "filteringFromTo": m2,
    "filteringLastMonth": MessageLookupByLibrary.simpleMessage(
      "Filtrando por el mes pasado",
    ),
    "filteringToday": MessageLookupByLibrary.simpleMessage("Filtrando por hoy"),
    "filters": MessageLookupByLibrary.simpleMessage("Filtros"),
    "finish": MessageLookupByLibrary.simpleMessage("Finalizar"),
    "forgotPassword": MessageLookupByLibrary.simpleMessage(
      "Recuperar contraseña",
    ),
    "forgotPasswordConfirmation1": MessageLookupByLibrary.simpleMessage(
      "Enviamos un correo electrónico a ",
    ),
    "forgotPasswordConfirmation2": MessageLookupByLibrary.simpleMessage(
      " para recuperar tu contraseña. Después de recibir el correo, sigue el enlace proporcionado para iniciar sesión.",
    ),
    "forgotPasswordInfo": MessageLookupByLibrary.simpleMessage(
      "Ingresa tu correo electrónico para recibir el enlace para restablecer tu contraseña.",
    ),
    "forgotYourPassword": MessageLookupByLibrary.simpleMessage(
      "¿Olvidaste tu contraseña?",
    ),
    "fortnight": MessageLookupByLibrary.simpleMessage("Quincena"),
    "fromTo": m3,
    "googleSignIn": MessageLookupByLibrary.simpleMessage(
      "Iniciar sesión con Google",
    ),
    "hi": m4,
    "home": MessageLookupByLibrary.simpleMessage("Inicio"),
    "inUse": m5,
    "invalidIntNumber": MessageLookupByLibrary.simpleMessage(
      "Por favor, ingresa un número entero válido",
    ),
    "invalidNumber": MessageLookupByLibrary.simpleMessage(
      "Por favor, ingresa un número válido",
    ),
    "invalidProperty": m6,
    "isEmpty": m7,
    "lastMonth": MessageLookupByLibrary.simpleMessage("Mes pasado"),
    "lastServices": MessageLookupByLibrary.simpleMessage("Últimos servicios"),
    "leaveApp": MessageLookupByLibrary.simpleMessage(
      "¿Realmente deseas salir de la aplicación?",
    ),
    "lightMode": MessageLookupByLibrary.simpleMessage("Modo claro"),
    "logout": MessageLookupByLibrary.simpleMessage("Salir"),
    "logoutConfirmation": MessageLookupByLibrary.simpleMessage(
      "¿Realmente deseas cerrar sesión?",
    ),
    "month": MessageLookupByLibrary.simpleMessage("Mes"),
    "myBalance": MessageLookupByLibrary.simpleMessage("Mi saldo"),
    "name": MessageLookupByLibrary.simpleMessage("Nombre"),
    "newClient": MessageLookupByLibrary.simpleMessage("Nuevo cliente"),
    "newPassword": MessageLookupByLibrary.simpleMessage("Nueva contraseña"),
    "newService": MessageLookupByLibrary.simpleMessage("Nuevo servicio"),
    "newServiceType": MessageLookupByLibrary.simpleMessage(
      "Nuevo tipo de servicio",
    ),
    "newType": MessageLookupByLibrary.simpleMessage("Nuevo tipo"),
    "next": MessageLookupByLibrary.simpleMessage("Siguiente"),
    "noResults": MessageLookupByLibrary.simpleMessage("Sin resultados"),
    "noServiceTypes": MessageLookupByLibrary.simpleMessage(
      "Parece que no registraste ningún tipo de servicio. Haz clic en el botón de arriba para registrar uno nuevo.",
    ),
    "noServices": MessageLookupByLibrary.simpleMessage(
      "Parece que no registraste ningún servicio. Haz clic en el botón de arriba para registrar uno nuevo.\n\nRecuerda que aquí verás los servicios realizados hoy. Para ver otras fechas, ve a la pantalla de servicios.",
    ),
    "noServicesHome": MessageLookupByLibrary.simpleMessage(
      "Parece que no registraste ningún servicio para hoy. Haz clic en el botón de arriba para registrar uno nuevo.\n\nPor defecto se muestran los servicios realizados este mes. Intenta cambiar los filtros para ver otras fechas.",
    ),
    "numberBiggerThan100": MessageLookupByLibrary.simpleMessage(
      "Por favor, ingresa un número menor o igual a 100",
    ),
    "numberLesserThanZero": MessageLookupByLibrary.simpleMessage(
      "Por favor, ingresa un número mayor o igual a cero",
    ),
    "onboardingSubtitle": MessageLookupByLibrary.simpleMessage(
      "Esta herramienta inteligente fue diseñada para ayudarte a gestionar mejor tus servicios.",
    ),
    "onboardingTitle1": MessageLookupByLibrary.simpleMessage(
      "Calcula las\nganancias de ",
    ),
    "onboardingTitle2": MessageLookupByLibrary.simpleMessage("tus\nservicios"),
    "or": MessageLookupByLibrary.simpleMessage("o"),
    "orderAlphabetical": MessageLookupByLibrary.simpleMessage("Alfabético"),
    "orderBy": MessageLookupByLibrary.simpleMessage("Ordenar por"),
    "orderDateAsc": MessageLookupByLibrary.simpleMessage(
      "Más antiguo a más reciente",
    ),
    "orderDateDesc": MessageLookupByLibrary.simpleMessage(
      "Más reciente a más antiguo",
    ),
    "orderValueAsc": MessageLookupByLibrary.simpleMessage("Menor a mayor"),
    "orderValueDesc": MessageLookupByLibrary.simpleMessage("Mayor a menor"),
    "password": MessageLookupByLibrary.simpleMessage("Contraseña"),
    "period": MessageLookupByLibrary.simpleMessage("Período"),
    "phone": MessageLookupByLibrary.simpleMessage("Teléfono"),
    "pricayPoliceLinks": MessageLookupByLibrary.simpleMessage(
      "Este Servicio puede contener enlaces a otros sitios. Si haces clic en un enlace de terceros, serás redirigido a ese sitio. Ten en cuenta que estos sitios externos no son operados por mí. Por lo tanto, te recomiendo encarecidamente que revises la Política de Privacidad de esos sitios. No tengo control ni asumo responsabilidad alguna por el contenido, las políticas de privacidad o las prácticas de sitios o servicios de terceros.",
    ),
    "pricayPoliceLinksTitle": MessageLookupByLibrary.simpleMessage(
      "Enlaces a otros sitios",
    ),
    "privacyPolice": MessageLookupByLibrary.simpleMessage(
      "Política de privacidad",
    ),
    "privacyPoliceChanges": MessageLookupByLibrary.simpleMessage(
      "Puedo actualizar nuestra Política de Privacidad ocasionalmente. Por ello, se recomienda revisar esta página periódicamente para verificar cambios. Te notificaré cualquier cambio publicando la nueva Política de Privacidad en esta página.\nEsta política es efectiva a partir del 26-05-2023",
    ),
    "privacyPoliceChangesTitle": MessageLookupByLibrary.simpleMessage(
      "Cambios en esta Política de Privacidad",
    ),
    "privacyPoliceChildren": MessageLookupByLibrary.simpleMessage(
      "Estos Servicios no están dirigidos a menores de 13 años. No recopilo intencionalmente información personal identificable de niños menores de 13 años. En caso de descubrir que un niño menor de 13 años me proporcionó información personal, la eliminaré inmediatamente de nuestros servidores. Si eres padre, madre o tutor y sabes que tu hijo nos proporcionó información personal, contáctame para que pueda tomar las medidas necesarias.",
    ),
    "privacyPoliceChildrenTitle": MessageLookupByLibrary.simpleMessage(
      "Privacidad de los niños",
    ),
    "privacyPoliceContact": MessageLookupByLibrary.simpleMessage(
      "Si tienes alguna pregunta o sugerencia sobre mi Política de Privacidad, no dudes en contactarme en ",
    ),
    "privacyPoliceContactTitle": MessageLookupByLibrary.simpleMessage(
      "Contáctanos",
    ),
    "privacyPoliceCookies": MessageLookupByLibrary.simpleMessage(
      "Las cookies son archivos con una pequeña cantidad de datos que se utilizan comúnmente como identificadores únicos anónimos. Se envían a tu navegador desde los sitios web que visitas y se almacenan en la memoria interna de tu dispositivo.\nEste Servicio no utiliza estas cookies explícitamente. Sin embargo, la aplicación puede usar código y bibliotecas de terceros que utilizan cookies para recopilar información y mejorar sus servicios. Tienes la opción de aceptar o rechazar estas cookies y saber cuándo se envía una cookie a tu dispositivo. Si decides rechazar nuestras cookies, es posible que no puedas usar algunas partes de este Servicio.",
    ),
    "privacyPoliceCookiesTitle": MessageLookupByLibrary.simpleMessage(
      "Cookies",
    ),
    "privacyPoliceEnd": MessageLookupByLibrary.simpleMessage(
      "Esta página de política de privacidad fue creada en privacypolicytemplate.net y modificada/generada por App Privacy Policy Generator.",
    ),
    "privacyPoliceInformation": MessageLookupByLibrary.simpleMessage(
      "Para una mejor experiencia al usar nuestro Servicio, puedo requerir que nos proporciones cierta información de identificación personal, incluyendo, entre otros, nombre y correo electrónico. La información solicitada se mantendrá en tu dispositivo y no será recopilada por mí de ninguna forma.\nLa aplicación utiliza servicios de terceros que pueden recopilar información utilizada para identificarte.\nEnlace a las políticas de privacidad de los proveedores de servicios de terceros utilizados por la aplicación:\n",
    ),
    "privacyPoliceInformation1": MessageLookupByLibrary.simpleMessage(
      "Servicios de Google Play",
    ),
    "privacyPoliceInformation2": MessageLookupByLibrary.simpleMessage("AdMob"),
    "privacyPoliceInformation3": MessageLookupByLibrary.simpleMessage(
      "Google Analytics",
    ),
    "privacyPoliceInformation4": MessageLookupByLibrary.simpleMessage(
      "Firebase Crashlytics",
    ),
    "privacyPoliceInformationTitle": MessageLookupByLibrary.simpleMessage(
      "Recopilación y uso de información",
    ),
    "privacyPoliceLogData": MessageLookupByLibrary.simpleMessage(
      "Quiero informarte que cada vez que utilizas mi Servicio, en caso de error en la aplicación, recopilo datos e información (a través de productos de terceros) en tu teléfono, denominados Datos de Registro. Estos pueden incluir información como la dirección IP del dispositivo, nombre del dispositivo, versión del sistema operativo, configuración de la aplicación al usar mi servicio, hora y fecha de uso y otras estadísticas.",
    ),
    "privacyPoliceLogDataTitle": MessageLookupByLibrary.simpleMessage(
      "Datos de registro",
    ),
    "privacyPoliceSecurity": MessageLookupByLibrary.simpleMessage(
      "Valoro tu confianza al proporcionarnos tu información personal, por lo que nos esforzamos por utilizar medios comercialmente aceptables para protegerla. Sin embargo, recuerda que ningún método de transmisión por Internet ni de almacenamiento electrónico es 100% seguro y confiable, y no puedo garantizar su seguridad absoluta.",
    ),
    "privacyPoliceSecurityTitle": MessageLookupByLibrary.simpleMessage(
      "Seguridad",
    ),
    "privacyPoliceServices": MessageLookupByLibrary.simpleMessage(
      "Puedo contratar empresas e individuos terceros por los siguientes motivos:\n\nPara facilitar nuestro Servicio;\nPara proporcionar el Servicio en nuestro nombre;\nPara realizar servicios relacionados con el Servicio; o\nPara ayudarnos a analizar cómo se utiliza nuestro Servicio.\n\nDeseo informar a los usuarios de este Servicio que estos terceros tienen acceso a su información personal. El motivo es realizar las tareas asignadas en nuestro nombre. Sin embargo, están obligados a no divulgar ni usar la información para ningún otro fin.",
    ),
    "privacyPoliceServicesTitle": MessageLookupByLibrary.simpleMessage(
      "Proveedores de servicios",
    ),
    "privacyPoliceStart": MessageLookupByLibrary.simpleMessage(
      "Lucas Guimarães creó la aplicación Kazi como una aplicación con anuncios. Este SERVICIO es proporcionado por Lucas Guimarães sin costo y está destinado a ser utilizado tal como está.\nEsta página se utiliza para informar a los visitantes sobre mis políticas de recopilación, uso y divulgación de información personal, en caso de que alguien decida utilizar mi servicio.\nSi decides usar mi servicio, aceptas la recopilación y el uso de información relacionada con esta política. La información personal que recopilo se utiliza para proporcionar y mejorar el Servicio. No usaré ni compartiré tu información con nadie, excepto como se describe en esta Política de Privacidad.\nLos términos utilizados en esta Política de Privacidad tienen los mismos significados que en nuestros Términos y Condiciones, que pueden consultarse en Kazi, salvo que se defina lo contrario en esta Política de Privacidad.",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("Perfil"),
    "quantity": MessageLookupByLibrary.simpleMessage("Cantidad"),
    "removeFilters": MessageLookupByLibrary.simpleMessage("Eliminar filtros"),
    "requiredProperty": m8,
    "resendEmail": MessageLookupByLibrary.simpleMessage("Reenviar correo"),
    "resetedPassword": MessageLookupByLibrary.simpleMessage(
      "Contraseña restablecida con éxito",
    ),
    "role": MessageLookupByLibrary.simpleMessage("Función"),
    "save": MessageLookupByLibrary.simpleMessage("Guardar"),
    "saveService": MessageLookupByLibrary.simpleMessage("Guardar servicio"),
    "saveType": MessageLookupByLibrary.simpleMessage("Guardar tipo"),
    "search": MessageLookupByLibrary.simpleMessage("Buscar"),
    "selectServiceType": MessageLookupByLibrary.simpleMessage(
      "Selecciona el tipo de servicio",
    ),
    "sendEmail": MessageLookupByLibrary.simpleMessage("Enviar correo"),
    "service": MessageLookupByLibrary.simpleMessage("Servicio"),
    "serviceAdded": MessageLookupByLibrary.simpleMessage(
      "Servicio agregado con éxito",
    ),
    "serviceDeleted": MessageLookupByLibrary.simpleMessage(
      "Servicio eliminado con éxito",
    ),
    "serviceType": MessageLookupByLibrary.simpleMessage("Tipo de servicio"),
    "serviceTypes": MessageLookupByLibrary.simpleMessage("Tipos de servicio"),
    "serviceUpdated": MessageLookupByLibrary.simpleMessage(
      "Servicio editado con éxito",
    ),
    "serviceValue": MessageLookupByLibrary.simpleMessage("Valor del servicio"),
    "services": MessageLookupByLibrary.simpleMessage("Servicios"),
    "settings": MessageLookupByLibrary.simpleMessage("Configuraciones"),
    "share": MessageLookupByLibrary.simpleMessage("Compartir"),
    "signIn": MessageLookupByLibrary.simpleMessage("Ingresar"),
    "signUp": MessageLookupByLibrary.simpleMessage("Registrarse"),
    "signUpSuccess": MessageLookupByLibrary.simpleMessage(
      "Registro realizado con éxito",
    ),
    "skip": MessageLookupByLibrary.simpleMessage("Omitir"),
    "thisService": MessageLookupByLibrary.simpleMessage("este servicio"),
    "today": MessageLookupByLibrary.simpleMessage("Hoy"),
    "total": MessageLookupByLibrary.simpleMessage("Valor total"),
    "totalReceived": MessageLookupByLibrary.simpleMessage("Total recibido"),
    "tourAppBarDescription": MessageLookupByLibrary.simpleMessage(
      "Aquí puedes registrar los tipos de servicios que realizas y cerrar sesión.",
    ),
    "tourAppBarTitle": MessageLookupByLibrary.simpleMessage("Área del perfil"),
    "tourBottomNavigationServicesDescription": MessageLookupByLibrary.simpleMessage(
      "En este menú encontrarás todos los servicios realizados y podrás registrar uno nuevo.",
    ),
    "tourBottomNavigationServicesTitle": MessageLookupByLibrary.simpleMessage(
      "Área de servicios",
    ),
    "tourHomeBalanceDescription": MessageLookupByLibrary.simpleMessage(
      "Aquí se muestran tus ganancias diarias, el total descontado y el total recibido.",
    ),
    "tourHomeBalanceTitle": MessageLookupByLibrary.simpleMessage("Balance"),
    "tourHomeServicesDescription": MessageLookupByLibrary.simpleMessage(
      "Estos son los servicios que realizaste hoy.",
    ),
    "tourHomeServicesTitle": MessageLookupByLibrary.simpleMessage(
      "Servicios del día",
    ),
    "tourProfileDescription": MessageLookupByLibrary.simpleMessage(
      "Aquí encontrarás algunas acciones disponibles, incluyendo registrar un nuevo tipo de servicio. El tipo de servicio te permite identificar fácilmente un servicio prestado.",
    ),
    "tourProfileTitle": MessageLookupByLibrary.simpleMessage("Acciones"),
    "tourServiceDetailsDescription": MessageLookupByLibrary.simpleMessage(
      "Al hacer clic en el servicio, puedes ver toda su información, editarlo o eliminarlo.",
    ),
    "tourServiceDetailsTitle": MessageLookupByLibrary.simpleMessage(
      "Detalles del servicio",
    ),
    "tourServiceTypesDescription": MessageLookupByLibrary.simpleMessage(
      "Esta información te ayudará a registrar fácilmente los servicios. Puedes asignar un nombre, como \"Pestañas - Volumen Brasileño\", completar el valor predeterminado y, si corresponde, el porcentaje que normalmente se descuenta.",
    ),
    "tourServiceTypesTitle": MessageLookupByLibrary.simpleMessage(
      "Tipo de servicio",
    ),
    "tourServicesForm1Description": MessageLookupByLibrary.simpleMessage(
      "Para registrar un nuevo servicio, primero selecciona uno de los tipos de servicio registrados previamente y los valores se completarán automáticamente. Si lo deseas, puedes modificar los valores para este servicio específico.",
    ),
    "tourServicesForm1Title": MessageLookupByLibrary.simpleMessage(
      "Registrar servicio",
    ),
    "tourServicesForm2Description": MessageLookupByLibrary.simpleMessage(
      "Solo selecciona la fecha del servicio, la cantidad realizada y completa una descripción o nota si lo deseas.",
    ),
    "tourServicesForm2Title": MessageLookupByLibrary.simpleMessage(
      "Registrar servicio",
    ),
    "tourServicesInfoDescription": MessageLookupByLibrary.simpleMessage(
      "Aquí puedes filtrar y ordenar los servicios, así como ver el saldo del período seleccionado. También puedes registrar los servicios realizados.",
    ),
    "tourServicesInfoTitle": MessageLookupByLibrary.simpleMessage("Servicios"),
    "tourServicesListDescription": MessageLookupByLibrary.simpleMessage(
      "Estos son todos los servicios realizados en un período determinado. Por defecto verás los servicios de este mes.",
    ),
    "tourServicesListTitle": MessageLookupByLibrary.simpleMessage("Servicios"),
    "updatePassword": MessageLookupByLibrary.simpleMessage(
      "Actualizar contraseña",
    ),
    "userTermsAlert1": MessageLookupByLibrary.simpleMessage(
      "Al continuar, aceptas los ",
    ),
    "userTermsAlert2": MessageLookupByLibrary.simpleMessage(
      "Términos de servicio ",
    ),
    "userTermsAlert3": MessageLookupByLibrary.simpleMessage(
      "y confirmas que has leído nuestra ",
    ),
    "userTermsAlert4": MessageLookupByLibrary.simpleMessage(
      "Política de privacidad",
    ),
    "validatorConfirmPassword": MessageLookupByLibrary.simpleMessage(
      "Las contraseñas no coinciden",
    ),
    "validatorEmail": MessageLookupByLibrary.simpleMessage(
      "Correo electrónico inválido",
    ),
    "validatorPassword": MessageLookupByLibrary.simpleMessage(
      "Tu contraseña debe tener al menos 8 caracteres y como máximo 16",
    ),
    "week": MessageLookupByLibrary.simpleMessage("Semana"),
    "wouldYouLikeDelete": m9,
    "yesterday": MessageLookupByLibrary.simpleMessage("Ayer"),
    "yourEarnings": MessageLookupByLibrary.simpleMessage(
      "Tus ganancias de hoy",
    ),
  };
}
