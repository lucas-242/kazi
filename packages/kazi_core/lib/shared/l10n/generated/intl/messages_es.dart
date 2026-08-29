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

  static String m1(amount) => "${amount} ya recibidos";

  static String m2(date) => "Archivado el ${date}";

  static String m3(name) => "${name} archivado.";

  static String m4(range) => "Ciclo actual: ${range}";

  static String m5(count) =>
      "${Intl.plural(count, one: 'No se puede eliminar: 1 servicio usa este registro.', other: 'No se puede eliminar: ${count} servicios usan este registro.')}";

  static String m6(name) =>
      "\"${name}\" ya existe en tu catálogo, archivado. ¿Quieres restaurarlo?";

  static String m7(done, total) => "${done}/${total}";

  static String m8(name) =>
      "Ya tienes un cliente con este documento: ${name}. ¿Guardar de todos modos?";

  static String m9(name) =>
      "${name} ya está registrado con este documento, archivado. ¿Guardar un cliente nuevo de todos modos?";

  static String m10(name) =>
      "Ya tienes un cliente llamado ${name}. ¿Guardar este también?";

  static String m11(count) =>
      "${Intl.plural(count, one: '1 servicio del catálogo no tiene comisión', other: '${count} servicios del catálogo no tienen comisión')}";

  static String m12(percent) => "Comisión ${percent}";

  static String m13(count) =>
      "Lo aplicaremos a ${count} servicios ya registrados.";

  static String m14(days) =>
      "${Intl.plural(days, zero: 'cierra hoy', one: 'cierra mañana', other: 'cierra en ${days} días')}";

  static String m15(count, amount) =>
      "${Intl.plural(count, one: 'de ${amount} generados en 1 servicio', other: 'de ${amount} generados en ${count} servicios')}";

  static String m16(name) =>
      "¿Eliminar ${name} definitivamente? Sus datos de contacto se borran y no se pueden recuperar.";

  static String m17(count) =>
      "${Intl.plural(count, one: 'El servicio ya realizado sigue en el historial, con el nombre.', other: 'Los ${count} servicios ya realizados siguen en el historial, con el nombre.')}";

  static String m18(name) =>
      "¿Eliminar ${name} definitivamente? Esta acción no se puede deshacer.";

  static String m19(url) => "No fue posible abrir la URL ${url}";

  static String m20(start, end) => "Filtrando desde ${start} hasta ${end}";

  static String m21(count) => "${count} servicios en el catálogo";

  static String m22(count) => "${count} clientes";

  static String m23(count) => "${count} servicios / mes";

  static String m24(start, end) => "Desde ${start} hasta ${end}";

  static String m25(person) => "¡Hola, ${person}!";

  static String m26(property) => "${property} está en uso";

  static String m27(property) => "${property} inválido";

  static String m28(property) => "${property} está vacío";

  static String m29(privacy) => "Al continuar, aceptas la ${privacy}.";

  static String m30(count) =>
      "${Intl.plural(count, one: 'Marcar 1 como recibido', other: 'Marcar ${count} como recibidos')}";

  static String m31(count) =>
      "${Intl.plural(count, one: '¿Marcar este servicio como recibido? Puedes deshacerlo enseguida.', other: '¿Marcar estos ${count} servicios como recibidos? Puedes deshacerlo enseguida.')}";

  static String m32(amount) => "de ${amount}";

  static String m33(price) => "${price}/mes";

  static String m34(price) => "7 días gratis, luego ${price}/mes.";

  static String m35(date) => "Recibido el ${date}";

  static String m36(property) => "${property} debe ser completado";

  static String m37(name) => "${name} restaurado.";

  static String m38(count) =>
      "${Intl.plural(count, one: '1 servicio', other: '${count} servicios')}";

  static String m39(count) => "Continuar con ${count}";

  static String m40(day) => "día ${day}";

  static String m41(total, percent) => "de ${total} · comisión del ${percent}";

  static String m42(amount) => "A recibir: ${amount}";

  static String m43(count) =>
      "${Intl.plural(count, one: 'Hoy · 1 servicio', other: 'Hoy · ${count} servicios')}";

  static String m44(count) => "Ver archivados · ${count}";

  static String m45(item) => "¿Deseas eliminar ${item}?";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("Acerca de"),
    "actions": MessageLookupByLibrary.simpleMessage("Acciones"),
    "add": MessageLookupByLibrary.simpleMessage("Agregar"),
    "addClient": MessageLookupByLibrary.simpleMessage("Agregar cliente"),
    "address": MessageLookupByLibrary.simpleMessage("Dirección"),
    "all": MessageLookupByLibrary.simpleMessage("Todos"),
    "allClients": MessageLookupByLibrary.simpleMessage("Todos los clientes"),
    "allReceipts": MessageLookupByLibrary.simpleMessage("Todos"),
    "alreadyExists": m0,
    "alreadyHasAccont": MessageLookupByLibrary.simpleMessage(
      "¿Ya tienes una cuenta? ",
    ),
    "alreadyReceived": m1,
    "appSubtitle": MessageLookupByLibrary.simpleMessage(
      "Organiza tus servicios",
    ),
    "applyFilters": MessageLookupByLibrary.simpleMessage("Aplicar filtros"),
    "archive": MessageLookupByLibrary.simpleMessage("Archivar"),
    "archived": MessageLookupByLibrary.simpleMessage("Archivado"),
    "archivedCatalogItems": MessageLookupByLibrary.simpleMessage(
      "Catálogo archivado",
    ),
    "archivedClients": MessageLookupByLibrary.simpleMessage(
      "Clientes archivados",
    ),
    "archivedOn": m2,
    "archivedSectionLabel": MessageLookupByLibrary.simpleMessage("Archivados"),
    "archivedSnackbar": m3,
    "attention": MessageLookupByLibrary.simpleMessage("Atención"),
    "back": MessageLookupByLibrary.simpleMessage("Volver"),
    "billingCycle": MessageLookupByLibrary.simpleMessage("Ciclo de pago"),
    "billingCycleDescription": MessageLookupByLibrary.simpleMessage(
      "La ventana que suma tu pantalla de inicio. Ajústala para que coincida con el día en que cobras.",
    ),
    "billingCycleFortnightly": MessageLookupByLibrary.simpleMessage(
      "Quincenal",
    ),
    "billingCycleMonthly": MessageLookupByLibrary.simpleMessage("Mensual"),
    "billingCyclePayday": MessageLookupByLibrary.simpleMessage(
      "Día en que cobro",
    ),
    "billingCyclePaydayWeekday": MessageLookupByLibrary.simpleMessage(
      "Día de la semana en que cobro",
    ),
    "billingCyclePreview": m4,
    "billingCycleWeekly": MessageLookupByLibrary.simpleMessage("Semanal"),
    "birthDate": MessageLookupByLibrary.simpleMessage("Fecha de nacimiento"),
    "byCatalogItem": MessageLookupByLibrary.simpleMessage("Por servicio"),
    "calculator": MessageLookupByLibrary.simpleMessage("Calculadora"),
    "calendar": MessageLookupByLibrary.simpleMessage("Calendario"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
    "cantDeleteLinkedServices": m5,
    "catalogItem": MessageLookupByLibrary.simpleMessage("Servicio"),
    "catalogItemArchivedRestorePrompt": m6,
    "catalogItems": MessageLookupByLibrary.simpleMessage("Catálogo"),
    "changePassword": MessageLookupByLibrary.simpleMessage(
      "Cambiar contraseña",
    ),
    "checklistBuildCatalog": MessageLookupByLibrary.simpleMessage(
      "Armar tu catálogo",
    ),
    "checklistFinished": MessageLookupByLibrary.simpleMessage(
      "Listo. De aquí en adelante, solo registrar.",
    ),
    "checklistFirstService": MessageLookupByLibrary.simpleMessage(
      "Registrar el primer servicio",
    ),
    "checklistMarkReceived": MessageLookupByLibrary.simpleMessage(
      "Marcar un servicio como recibido",
    ),
    "checklistProgress": m7,
    "checklistSeeSummary": MessageLookupByLibrary.simpleMessage(
      "Ver el resumen de tu mes",
    ),
    "checklistThreeServices": MessageLookupByLibrary.simpleMessage(
      "Registrar 3 servicios seguidos",
    ),
    "checklistTitle": MessageLookupByLibrary.simpleMessage(
      "Deja Kazi a tu manera",
    ),
    "client": MessageLookupByLibrary.simpleMessage("Cliente"),
    "clientSameDocument": m8,
    "clientSameDocumentArchived": m9,
    "clientSameName": m10,
    "clients": MessageLookupByLibrary.simpleMessage("Clientes"),
    "clientsEmptyExplained": MessageLookupByLibrary.simpleMessage(
      "Tus clientes aparecen aquí a medida que registras servicios. También puedes agregar uno ahora.",
    ),
    "clipperCut": MessageLookupByLibrary.simpleMessage("Corte con máquina"),
    "close": MessageLookupByLibrary.simpleMessage("Cerrar"),
    "color": MessageLookupByLibrary.simpleMessage("Color"),
    "commissionGapsBody": MessageLookupByLibrary.simpleMessage(
      "Sin eso entran en el total generado, pero no en lo que recibes.",
    ),
    "commissionGapsCta": MessageLookupByLibrary.simpleMessage(
      "Definir ahora · 30 seg",
    ),
    "commissionGapsTitle": m11,
    "commissionPercent": m12,
    "commissionPercentage": MessageLookupByLibrary.simpleMessage(
      "Porcentaje de la comisión",
    ),
    "commissionValue": MessageLookupByLibrary.simpleMessage(
      "Valor de la comisión",
    ),
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
    "continueWithGoogle": MessageLookupByLibrary.simpleMessage(
      "Continuar con Google",
    ),
    "create": MessageLookupByLibrary.simpleMessage("Crear"),
    "createAccount": MessageLookupByLibrary.simpleMessage("Crear una cuenta"),
    "currency": MessageLookupByLibrary.simpleMessage("Moneda"),
    "currencyAED": MessageLookupByLibrary.simpleMessage(
      "Dírham de los Emiratos Árabes",
    ),
    "currencyAOA": MessageLookupByLibrary.simpleMessage("Kwanza angoleño"),
    "currencyARS": MessageLookupByLibrary.simpleMessage("Peso argentino"),
    "currencyBOB": MessageLookupByLibrary.simpleMessage("Boliviano"),
    "currencyBRL": MessageLookupByLibrary.simpleMessage("Real brasileño"),
    "currencyCAD": MessageLookupByLibrary.simpleMessage("Dólar canadiense"),
    "currencyCHF": MessageLookupByLibrary.simpleMessage("Franco suizo"),
    "currencyCLP": MessageLookupByLibrary.simpleMessage("Peso chileno"),
    "currencyCNY": MessageLookupByLibrary.simpleMessage("Yuan chino"),
    "currencyCOP": MessageLookupByLibrary.simpleMessage("Peso colombiano"),
    "currencyCRC": MessageLookupByLibrary.simpleMessage("Colón costarricense"),
    "currencyCUP": MessageLookupByLibrary.simpleMessage("Peso cubano"),
    "currencyDOP": MessageLookupByLibrary.simpleMessage("Peso dominicano"),
    "currencyETB": MessageLookupByLibrary.simpleMessage("Birr etíope"),
    "currencyEUR": MessageLookupByLibrary.simpleMessage("Euro"),
    "currencyGBP": MessageLookupByLibrary.simpleMessage("Libra esterlina"),
    "currencyGHS": MessageLookupByLibrary.simpleMessage("Cedi ghanés"),
    "currencyGTQ": MessageLookupByLibrary.simpleMessage("Quetzal guatemalteco"),
    "currencyHNL": MessageLookupByLibrary.simpleMessage("Lempira hondureña"),
    "currencyHTG": MessageLookupByLibrary.simpleMessage("Gourde haitiano"),
    "currencyINR": MessageLookupByLibrary.simpleMessage("Rupia india"),
    "currencyJPY": MessageLookupByLibrary.simpleMessage("Yen japonés"),
    "currencyKES": MessageLookupByLibrary.simpleMessage("Chelín keniano"),
    "currencyKRW": MessageLookupByLibrary.simpleMessage("Won surcoreano"),
    "currencyMAD": MessageLookupByLibrary.simpleMessage("Dírham marroquí"),
    "currencyMXN": MessageLookupByLibrary.simpleMessage("Peso mexicano"),
    "currencyMigrationApplying": MessageLookupByLibrary.simpleMessage(
      "Actualizando tus servicios…",
    ),
    "currencyMigrationChangeLater": MessageLookupByLibrary.simpleMessage(
      "Puedes cambiarlo después en Ajustes.",
    ),
    "currencyMigrationDescription": MessageLookupByLibrary.simpleMessage(
      "Kazi ahora admite varias monedas. Indícanos en cuál se registraron tus servicios existentes para que tus totales cuadren.",
    ),
    "currencyMigrationServicesCount": m13,
    "currencyMigrationTitle": MessageLookupByLibrary.simpleMessage(
      "¿En qué moneda trabajas?",
    ),
    "currencyNGN": MessageLookupByLibrary.simpleMessage("Naira nigeriana"),
    "currencyNIO": MessageLookupByLibrary.simpleMessage("Córdoba nicaragüense"),
    "currencyPAB": MessageLookupByLibrary.simpleMessage("Balboa panameño"),
    "currencyPEN": MessageLookupByLibrary.simpleMessage("Sol peruano"),
    "currencyPYG": MessageLookupByLibrary.simpleMessage("Guaraní paraguayo"),
    "currencyRUB": MessageLookupByLibrary.simpleMessage("Rublo ruso"),
    "currencySAR": MessageLookupByLibrary.simpleMessage("Riyal saudí"),
    "currencySGD": MessageLookupByLibrary.simpleMessage("Dólar de Singapur"),
    "currencyTRY": MessageLookupByLibrary.simpleMessage("Lira turca"),
    "currencyUGX": MessageLookupByLibrary.simpleMessage("Chelín ugandés"),
    "currencyUSD": MessageLookupByLibrary.simpleMessage("Dólar estadounidense"),
    "currencyUYU": MessageLookupByLibrary.simpleMessage("Peso uruguayo"),
    "currencyVES": MessageLookupByLibrary.simpleMessage("Bolívar venezolano"),
    "currencyXAF": MessageLookupByLibrary.simpleMessage(
      "Franco CFA de África Central",
    ),
    "currencyXOF": MessageLookupByLibrary.simpleMessage(
      "Franco CFA de África Occidental",
    ),
    "currencyZAR": MessageLookupByLibrary.simpleMessage("Rand sudafricano"),
    "currentCycle": MessageLookupByLibrary.simpleMessage("Ciclo actual"),
    "currentPassword": MessageLookupByLibrary.simpleMessage(
      "Contraseña actual",
    ),
    "cycleClosesIn": m14,
    "cycleConfirmBody": MessageLookupByLibrary.simpleMessage(
      "Ahora Kazi agrupa tus ganancias por el período en que cobras. Estamos sumando por mes, del día 1 al último. ¿Es así?",
    ),
    "cycleConfirmNo": MessageLookupByLibrary.simpleMessage(
      "Cobro de otra forma",
    ),
    "cycleConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Una sola pregunta y vuelvo a tu trabajo",
    ),
    "cycleConfirmYes": MessageLookupByLibrary.simpleMessage("Es así"),
    "cycleGeneratedIn": m15,
    "darkMode": MessageLookupByLibrary.simpleMessage("Modo oscuro"),
    "date": MessageLookupByLibrary.simpleMessage("Fecha"),
    "defaultCurrency": MessageLookupByLibrary.simpleMessage(
      "Moneda predeterminada",
    ),
    "defaultValue": MessageLookupByLibrary.simpleMessage(
      "Valor predeterminado",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Eliminar"),
    "deleteClientConfirm": m16,
    "deleteClientKeepsServices": m17,
    "deletePermanently": MessageLookupByLibrary.simpleMessage(
      "Eliminar definitivamente",
    ),
    "deletePermanentlyConfirm": m18,
    "description": MessageLookupByLibrary.simpleMessage("Descripción"),
    "details": MessageLookupByLibrary.simpleMessage("Detalles"),
    "didntReceiveAnything": MessageLookupByLibrary.simpleMessage(
      "¿No recibiste nada? ",
    ),
    "discountPercentage": MessageLookupByLibrary.simpleMessage(
      "Porcentaje de descuento",
    ),
    "discounts": MessageLookupByLibrary.simpleMessage("Descuentos"),
    "document": MessageLookupByLibrary.simpleMessage("Documento"),
    "doesntHaveAccount": MessageLookupByLibrary.simpleMessage(
      "¿No tienes una cuenta? ",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("Editar"),
    "editService": MessageLookupByLibrary.simpleMessage("Editar servicio"),
    "email": MessageLookupByLibrary.simpleMessage("Correo electrónico"),
    "employee": MessageLookupByLibrary.simpleMessage("Colaborador"),
    "employees": MessageLookupByLibrary.simpleMessage("Colaboradores"),
    "errorAccessDenied": MessageLookupByLibrary.simpleMessage(
      "Acceso denegado",
    ),
    "errorCantDeleteCatalogItem": MessageLookupByLibrary.simpleMessage(
      "Este servicio no puede eliminarse del catálogo porque está en uso",
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
    "errorLaunchUrl": m19,
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
    "errorToAddCatalogItem": MessageLookupByLibrary.simpleMessage(
      "Error al agregar el servicio al catálogo.",
    ),
    "errorToAddClient": MessageLookupByLibrary.simpleMessage(
      "Error al agregar cliente.",
    ),
    "errorToAddService": MessageLookupByLibrary.simpleMessage(
      "Error al agregar el servicio.",
    ),
    "errorToArchiveCatalogItem": MessageLookupByLibrary.simpleMessage(
      "Error al archivar el elemento del catálogo.",
    ),
    "errorToArchiveClient": MessageLookupByLibrary.simpleMessage(
      "Error al archivar el cliente.",
    ),
    "errorToCountServices": MessageLookupByLibrary.simpleMessage(
      "Error al obtener la cantidad de servicios.",
    ),
    "errorToDeleteCatalogItem": MessageLookupByLibrary.simpleMessage(
      "Error al eliminar el servicio del catálogo.",
    ),
    "errorToDeleteClient": MessageLookupByLibrary.simpleMessage(
      "Error al eliminar cliente.",
    ),
    "errorToDeleteService": MessageLookupByLibrary.simpleMessage(
      "Error al eliminar el servicio.",
    ),
    "errorToGetCatalogItems": MessageLookupByLibrary.simpleMessage(
      "Error al cargar tu catálogo.",
    ),
    "errorToGetClients": MessageLookupByLibrary.simpleMessage(
      "Error al obtener clientes.",
    ),
    "errorToGetServices": MessageLookupByLibrary.simpleMessage(
      "Error al obtener los servicios.",
    ),
    "errorToGetUserSettings": MessageLookupByLibrary.simpleMessage(
      "No pudimos cargar tus ajustes.",
    ),
    "errorToMarkReceived": MessageLookupByLibrary.simpleMessage(
      "Error al marcar los servicios como recibidos",
    ),
    "errorToMigrateCurrency": MessageLookupByLibrary.simpleMessage(
      "No pudimos actualizar tus servicios. Inténtalo de nuevo.",
    ),
    "errorToResetPassword": MessageLookupByLibrary.simpleMessage(
      "Error al restablecer la contraseña.",
    ),
    "errorToRestoreCatalogItem": MessageLookupByLibrary.simpleMessage(
      "Error al restaurar el elemento del catálogo.",
    ),
    "errorToRestoreClient": MessageLookupByLibrary.simpleMessage(
      "Error al restaurar el cliente.",
    ),
    "errorToSaveUserSettings": MessageLookupByLibrary.simpleMessage(
      "No pudimos guardar tus ajustes.",
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
    "errorToUpdateCatalogItem": MessageLookupByLibrary.simpleMessage(
      "Error al editar el servicio del catálogo.",
    ),
    "errorToUpdateClient": MessageLookupByLibrary.simpleMessage(
      "Error al actualizar cliente.",
    ),
    "errorToUpdateService": MessageLookupByLibrary.simpleMessage(
      "Error al editar el servicio.",
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
    "featureNoAds": MessageLookupByLibrary.simpleMessage("Sin anuncios"),
    "featureUnlimitedCatalog": MessageLookupByLibrary.simpleMessage(
      "Catálogo ilimitado",
    ),
    "featureUnlimitedClients": MessageLookupByLibrary.simpleMessage(
      "Clientes ilimitados",
    ),
    "featureUnlimitedServices": MessageLookupByLibrary.simpleMessage(
      "Servicios ilimitados",
    ),
    "field": MessageLookupByLibrary.simpleMessage("Campo"),
    "filteringFromTo": m20,
    "filteringLastMonth": MessageLookupByLibrary.simpleMessage(
      "Filtrando por el mes pasado",
    ),
    "filteringToday": MessageLookupByLibrary.simpleMessage("Filtrando por hoy"),
    "filters": MessageLookupByLibrary.simpleMessage("Filtros"),
    "finish": MessageLookupByLibrary.simpleMessage("Finalizar"),
    "forcedUpdateButton": MessageLookupByLibrary.simpleMessage(
      "Actualizar ahora",
    ),
    "forcedUpdateMessage": MessageLookupByLibrary.simpleMessage(
      "Hay una nueva versión de Kazi disponible. Actualiza para seguir usando la app.",
    ),
    "forcedUpdateTitle": MessageLookupByLibrary.simpleMessage(
      "Actualización necesaria",
    ),
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
    "freeLimitAds": MessageLookupByLibrary.simpleMessage("Con anuncios"),
    "freeLimitCatalogItems": m21,
    "freeLimitClients": m22,
    "freeLimitServices": m23,
    "freePlan": MessageLookupByLibrary.simpleMessage("Gratis"),
    "fromTo": m24,
    "generatedInPeriod": MessageLookupByLibrary.simpleMessage(
      "Generado en el período",
    ),
    "goPremium": MessageLookupByLibrary.simpleMessage("Hazte Premium"),
    "googleSignIn": MessageLookupByLibrary.simpleMessage(
      "Iniciar sesión con Google",
    ),
    "hi": m25,
    "hintFabBody": MessageLookupByLibrary.simpleMessage(
      "Cada vez que termines un servicio, toca la K en el centro de la barra. Elige el servicio, confirma y listo.",
    ),
    "hintFabTitle": MessageLookupByLibrary.simpleMessage(
      "Aquí es donde registras",
    ),
    "hintFiltersBody": MessageLookupByLibrary.simpleMessage(
      "Con algo de historial, los filtros encuentran un cliente, un período o un servicio.",
    ),
    "hintFiltersTitle": MessageLookupByLibrary.simpleMessage("Filtra la lista"),
    "hintGotIt": MessageLookupByLibrary.simpleMessage("Entendido"),
    "hintReceivedBody": MessageLookupByLibrary.simpleMessage(
      "Marcar un servicio como recibido cierra el ciclo entre lo que generaste y lo que cobraste.",
    ),
    "hintReceivedTitle": MessageLookupByLibrary.simpleMessage(
      "Márcalo cuando te paguen",
    ),
    "hintSummaryBody": MessageLookupByLibrary.simpleMessage(
      "El resumen muestra lo que generaste, lo que es tuyo y lo que ya cobraste.",
    ),
    "hintSummaryTitle": MessageLookupByLibrary.simpleMessage(
      "Tu mes, en un solo lugar",
    ),
    "home": MessageLookupByLibrary.simpleMessage("Inicio"),
    "howToUseKazi": MessageLookupByLibrary.simpleMessage("Cómo usar Kazi"),
    "inUse": m26,
    "invalidIntNumber": MessageLookupByLibrary.simpleMessage(
      "Por favor, ingresa un número entero válido",
    ),
    "invalidNumber": MessageLookupByLibrary.simpleMessage(
      "Por favor, ingresa un número válido",
    ),
    "invalidProperty": m27,
    "isEmpty": m28,
    "language": MessageLookupByLibrary.simpleMessage("Idioma"),
    "lastMonth": MessageLookupByLibrary.simpleMessage("Mes pasado"),
    "lastServices": MessageLookupByLibrary.simpleMessage("Últimos servicios"),
    "leaveApp": MessageLookupByLibrary.simpleMessage(
      "¿Realmente deseas salir de la aplicación?",
    ),
    "lightMode": MessageLookupByLibrary.simpleMessage("Modo claro"),
    "limitReachedCatalogTitle": MessageLookupByLibrary.simpleMessage(
      "Alcanzaste el límite de tu catálogo",
    ),
    "limitReachedClientsTitle": MessageLookupByLibrary.simpleMessage(
      "Alcanzaste el límite de clientes",
    ),
    "limitReachedServicesTitle": MessageLookupByLibrary.simpleMessage(
      "Alcanzaste el límite de servicios del mes",
    ),
    "limitReachedSubtitle": MessageLookupByLibrary.simpleMessage(
      "Hazte Premium para seguir agregando sin límites.",
    ),
    "list": MessageLookupByLibrary.simpleMessage("Lista"),
    "loadMore": MessageLookupByLibrary.simpleMessage("Cargar más"),
    "loading": MessageLookupByLibrary.simpleMessage("Cargando..."),
    "loginHeadline": MessageLookupByLibrary.simpleMessage(
      "Tu trabajo, con claridad.",
    ),
    "loginLegal": m29,
    "loginSubtitle": MessageLookupByLibrary.simpleMessage(
      "Entra para ver cuánto generas y cuánto recibes.",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("Salir"),
    "logoutConfirmation": MessageLookupByLibrary.simpleMessage(
      "¿Realmente deseas cerrar sesión?",
    ),
    "managePlan": MessageLookupByLibrary.simpleMessage("Gestionar plan"),
    "markListedReceived": m30,
    "markListedReceivedConfirm": m31,
    "markedAsReceived": MessageLookupByLibrary.simpleMessage(
      "Marcados como recibidos",
    ),
    "menu": MessageLookupByLibrary.simpleMessage("Menú"),
    "month": MessageLookupByLibrary.simpleMessage("Mes"),
    "myWork": MessageLookupByLibrary.simpleMessage("Mi trabajo"),
    "name": MessageLookupByLibrary.simpleMessage("Nombre"),
    "newCatalogItem": MessageLookupByLibrary.simpleMessage("Nuevo servicio"),
    "newClient": MessageLookupByLibrary.simpleMessage("Nuevo cliente"),
    "newPassword": MessageLookupByLibrary.simpleMessage("Nueva contraseña"),
    "newService": MessageLookupByLibrary.simpleMessage("Nuevo servicio"),
    "next": MessageLookupByLibrary.simpleMessage("Siguiente"),
    "noCatalogItems": MessageLookupByLibrary.simpleMessage(
      "Tu catálogo está vacío. Toca el botón de arriba para agregar el primer servicio.",
    ),
    "noClientsFound": MessageLookupByLibrary.simpleMessage(
      "No se encontraron clientes",
    ),
    "noColor": MessageLookupByLibrary.simpleMessage("Sin color"),
    "noResults": MessageLookupByLibrary.simpleMessage("Sin resultados"),
    "noServices": MessageLookupByLibrary.simpleMessage(
      "Parece que no registraste ningún servicio. Haz clic en el botón de arriba para registrar uno nuevo.\n\nRecuerda que aquí verás los servicios realizados hoy. Para ver otras fechas, ve a la pantalla de servicios.",
    ),
    "noServicesForFilters": MessageLookupByLibrary.simpleMessage(
      "Ningún servicio coincide con estos filtros.",
    ),
    "noServicesToday": MessageLookupByLibrary.simpleMessage(
      "Ningún servicio registrado hoy",
    ),
    "noServicesYet": MessageLookupByLibrary.simpleMessage(
      "Aún no hay servicios",
    ),
    "notReceived": MessageLookupByLibrary.simpleMessage("Aún no recibido"),
    "numberBiggerThan100": MessageLookupByLibrary.simpleMessage(
      "Por favor, ingresa un número menor o igual a 100",
    ),
    "numberLesserThanZero": MessageLookupByLibrary.simpleMessage(
      "Por favor, ingresa un número mayor o igual a cero",
    ),
    "ofGross": m32,
    "optional": MessageLookupByLibrary.simpleMessage("opcional"),
    "optionalUpdateMessage": MessageLookupByLibrary.simpleMessage(
      "Hay una nueva versión de Kazi disponible con mejoras. ¿Deseas actualizar ahora?",
    ),
    "optionalUpdateTitle": MessageLookupByLibrary.simpleMessage(
      "Actualización disponible",
    ),
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
    "paywallPricePerMonth": m33,
    "paywallRenewInfo": MessageLookupByLibrary.simpleMessage(
      "Se renueva automáticamente cada mes. Cancela cuando quieras.",
    ),
    "paywallRestore": MessageLookupByLibrary.simpleMessage("Restaurar compra"),
    "paywallStartTrial": MessageLookupByLibrary.simpleMessage(
      "Iniciar prueba gratis de 7 días",
    ),
    "paywallSubscribe": MessageLookupByLibrary.simpleMessage("Suscribirse"),
    "paywallSubtitle": MessageLookupByLibrary.simpleMessage(
      "Elimina todos los límites y anuncios.",
    ),
    "paywallTitle": MessageLookupByLibrary.simpleMessage(
      "Desbloquea Kazi Premium",
    ),
    "paywallTrialThenPrice": m34,
    "pendingReceipt": MessageLookupByLibrary.simpleMessage("A recibir"),
    "period": MessageLookupByLibrary.simpleMessage("Período"),
    "phone": MessageLookupByLibrary.simpleMessage("Teléfono"),
    "planComparisonTitle": MessageLookupByLibrary.simpleMessage(
      "Gratis vs Premium",
    ),
    "preferences": MessageLookupByLibrary.simpleMessage("Preferencias"),
    "premiumPlan": MessageLookupByLibrary.simpleMessage("Premium"),
    "premiumUnlimited": MessageLookupByLibrary.simpleMessage(
      "Todo ilimitado, sin anuncios",
    ),
    "presetCleaning": MessageLookupByLibrary.simpleMessage(
      "Limpieza y trabajo doméstico",
    ),
    "presetCleaningDeepClean": MessageLookupByLibrary.simpleMessage(
      "Limpieza profunda",
    ),
    "presetCleaningFullDay": MessageLookupByLibrary.simpleMessage(
      "Jornada completa",
    ),
    "presetCleaningHalfDay": MessageLookupByLibrary.simpleMessage(
      "Media jornada",
    ),
    "presetCleaningIroning": MessageLookupByLibrary.simpleMessage(
      "Planchado, por hora",
    ),
    "presetCleaningPostConstruction": MessageLookupByLibrary.simpleMessage(
      "Limpieza post obra",
    ),
    "presetDesign": MessageLookupByLibrary.simpleMessage("Diseño y creación"),
    "presetDesignBrandIdentity": MessageLookupByLibrary.simpleMessage(
      "Identidad visual",
    ),
    "presetDesignHourly": MessageLookupByLibrary.simpleMessage("Hora suelta"),
    "presetDesignLandingPage": MessageLookupByLibrary.simpleMessage(
      "Landing page",
    ),
    "presetDesignLogo": MessageLookupByLibrary.simpleMessage("Logo"),
    "presetDesignSocialPost": MessageLookupByLibrary.simpleMessage(
      "Post para redes",
    ),
    "presetEsthetics": MessageLookupByLibrary.simpleMessage("Estética y cejas"),
    "presetEstheticsBrowDesign": MessageLookupByLibrary.simpleMessage(
      "Diseño de cejas",
    ),
    "presetEstheticsBrowHenna": MessageLookupByLibrary.simpleMessage(
      "Diseño con henna",
    ),
    "presetEstheticsFacialCleansing": MessageLookupByLibrary.simpleMessage(
      "Limpieza facial",
    ),
    "presetEstheticsFullLegWax": MessageLookupByLibrary.simpleMessage(
      "Depilación de piernas",
    ),
    "presetEstheticsLashExtensions": MessageLookupByLibrary.simpleMessage(
      "Extensión de pestañas",
    ),
    "presetEstheticsPeeling": MessageLookupByLibrary.simpleMessage("Peeling"),
    "presetEstheticsUnderarmWax": MessageLookupByLibrary.simpleMessage(
      "Depilación de axilas",
    ),
    "presetEstheticsUpperLipWax": MessageLookupByLibrary.simpleMessage(
      "Depilación de bozo",
    ),
    "presetHair": MessageLookupByLibrary.simpleMessage("Peluquería y barbería"),
    "presetHairBeard": MessageLookupByLibrary.simpleMessage("Barba"),
    "presetHairBlowDry": MessageLookupByLibrary.simpleMessage("Brushing"),
    "presetHairColoring": MessageLookupByLibrary.simpleMessage("Coloración"),
    "presetHairConditioning": MessageLookupByLibrary.simpleMessage(
      "Hidratación",
    ),
    "presetHairCutAndBeard": MessageLookupByLibrary.simpleMessage(
      "Corte y barba",
    ),
    "presetHairHighlights": MessageLookupByLibrary.simpleMessage("Mechas"),
    "presetHairMensCut": MessageLookupByLibrary.simpleMessage(
      "Corte masculino",
    ),
    "presetHairWomensCut": MessageLookupByLibrary.simpleMessage(
      "Corte femenino",
    ),
    "presetHandyman": MessageLookupByLibrary.simpleMessage(
      "Montaje y reparaciones",
    ),
    "presetHandymanBed": MessageLookupByLibrary.simpleMessage(
      "Montaje de cama",
    ),
    "presetHandymanCallout": MessageLookupByLibrary.simpleMessage(
      "Visita técnica",
    ),
    "presetHandymanShelf": MessageLookupByLibrary.simpleMessage(
      "Estante o soporte",
    ),
    "presetHandymanTvMount": MessageLookupByLibrary.simpleMessage(
      "Instalación de TV",
    ),
    "presetHandymanWardrobe": MessageLookupByLibrary.simpleMessage(
      "Montaje de armario",
    ),
    "presetMakeup": MessageLookupByLibrary.simpleMessage("Maquillaje"),
    "presetMakeupBride": MessageLookupByLibrary.simpleMessage(
      "Maquillaje de novia",
    ),
    "presetMakeupBridesmaid": MessageLookupByLibrary.simpleMessage(
      "Maquillaje de madrina",
    ),
    "presetMakeupClass": MessageLookupByLibrary.simpleMessage(
      "Clase de automaquillaje",
    ),
    "presetMakeupGraduation": MessageLookupByLibrary.simpleMessage(
      "Maquillaje de graduación",
    ),
    "presetMakeupSocial": MessageLookupByLibrary.simpleMessage(
      "Maquillaje social",
    ),
    "presetManicure": MessageLookupByLibrary.simpleMessage(
      "Manicura y pedicura",
    ),
    "presetManicureExtensionRemoval": MessageLookupByLibrary.simpleMessage(
      "Retiro de uñas",
    ),
    "presetManicureFootSpa": MessageLookupByLibrary.simpleMessage(
      "Spa de pies",
    ),
    "presetManicureGelExtension": MessageLookupByLibrary.simpleMessage(
      "Uñas de gel",
    ),
    "presetManicureGelRefill": MessageLookupByLibrary.simpleMessage(
      "Mantenimiento de gel",
    ),
    "presetManicureHandsAndFeet": MessageLookupByLibrary.simpleMessage(
      "Manos y pies",
    ),
    "presetManicurePolishFeet": MessageLookupByLibrary.simpleMessage(
      "Esmaltado de pies",
    ),
    "presetManicurePolishHands": MessageLookupByLibrary.simpleMessage(
      "Esmaltado de manos",
    ),
    "presetManicureStrengthening": MessageLookupByLibrary.simpleMessage(
      "Blindaje de uñas",
    ),
    "presetMassage": MessageLookupByLibrary.simpleMessage("Masaje y bienestar"),
    "presetMassageContouring": MessageLookupByLibrary.simpleMessage(
      "Masaje modelador",
    ),
    "presetMassageHotStone": MessageLookupByLibrary.simpleMessage(
      "Piedras calientes",
    ),
    "presetMassageLymphatic": MessageLookupByLibrary.simpleMessage(
      "Drenaje linfático",
    ),
    "presetMassagePackTen": MessageLookupByLibrary.simpleMessage(
      "Paquete de 10 sesiones",
    ),
    "presetMassageRelaxing": MessageLookupByLibrary.simpleMessage(
      "Masaje relajante, 60 min",
    ),
    "presetOther": MessageLookupByLibrary.simpleMessage("Otra profesión"),
    "presetPersonalAssessment": MessageLookupByLibrary.simpleMessage(
      "Evaluación física",
    ),
    "presetPersonalMonthlyPlan": MessageLookupByLibrary.simpleMessage(
      "Mensual, 3× por semana",
    ),
    "presetPersonalOnlineProgram": MessageLookupByLibrary.simpleMessage(
      "Entrenamiento online",
    ),
    "presetPersonalPackEight": MessageLookupByLibrary.simpleMessage(
      "Paquete de 8 clases",
    ),
    "presetPersonalSingleSession": MessageLookupByLibrary.simpleMessage(
      "Clase suelta",
    ),
    "presetPersonalTrainer": MessageLookupByLibrary.simpleMessage(
      "Entrenamiento personal",
    ),
    "pricayPoliceLinks": MessageLookupByLibrary.simpleMessage(
      "Este Servicio puede contener enlaces a otros sitios. Si haces clic en un enlace de terceros, serás redirigido a ese sitio. Ten en cuenta que estos sitios externos no son operados por mí. Por lo tanto, te recomiendo encarecidamente que revises la Política de Privacidad de esos sitios. No tengo control ni asumo responsabilidad alguna por el contenido, las políticas de privacidad o las prácticas de sitios o servicios de terceros.",
    ),
    "pricayPoliceLinksTitle": MessageLookupByLibrary.simpleMessage(
      "Enlaces a otros sitios",
    ),
    "privacy": MessageLookupByLibrary.simpleMessage("Privacidad"),
    "privacyPolice": MessageLookupByLibrary.simpleMessage(
      "Política de privacidad",
    ),
    "privacyPoliceAnalytics": MessageLookupByLibrary.simpleMessage(
      "Para entender dónde estorba la aplicación y por qué la gente deja de usarla, recojo eventos de uso: qué pantallas abres, qué acciones completas, qué errores se te muestran y atributos técnicos como la versión de la app, el idioma y el tipo de dispositivo.\nEstos eventos describen comportamiento, nunca contenido. Jamás llevan los importes que registras, los nombres de tus clientes, tu correo electrónico ni ningún texto libre que escribas — la aplicación los elimina antes de enviar nada.\nLa base legal es mi interés legítimo en mejorar el Servicio, y puedes oponerte en cualquier momento en Menú > Privacidad.\nEncargados: Google Firebase Analytics (Google LLC) y PostHog (PostHog, Inc.), cuyos datos de esta aplicación se alojan en la Unión Europea.",
    ),
    "privacyPoliceAnalyticsTitle": MessageLookupByLibrary.simpleMessage(
      "Análisis de uso",
    ),
    "privacyPoliceChanges": MessageLookupByLibrary.simpleMessage(
      "Puedo actualizar nuestra Política de Privacidad de vez en cuando. Por lo tanto, se te aconseja revisar esta página periódicamente para ver si hay cambios. Te notificaré cualquier cambio publicando la nueva Política de Privacidad en esta página.\nEsta política entra en vigor el 2026-08-20.",
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
      "Para una mejor experiencia, al usar nuestro Servicio, puedo pedirte que nos proporciones cierta información de identificación personal, incluyendo, entre otras, tu nombre y dirección de correo electrónico, que provienen de la cuenta de Google con la que inicias sesión. Esa información, junto con los servicios, clientes y ajustes que registras, se guarda en tu cuenta para estar disponible en cualquier dispositivo en el que inicies sesión.\nLa aplicación también usa servicios de terceros que pueden recopilar información utilizada para identificarte.\nEnlace a la política de privacidad de los proveedores de servicios de terceros utilizados por la aplicación:\n",
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
    "privacyPoliceInformation5": MessageLookupByLibrary.simpleMessage(
      "RevenueCat",
    ),
    "privacyPoliceInformation6": MessageLookupByLibrary.simpleMessage(
      "PostHog",
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
    "privacyPoliceReplay": MessageLookupByLibrary.simpleMessage(
      "Con tu permiso explícito, y solo con él, la aplicación puede grabar una sesión como una secuencia de capturas de pantalla, para que yo vea dónde se atasca la gente.\nTodo texto y toda imagen se enmascaran en tu dispositivo antes de cualquier envío. Lo que se almacena muestra la disposición, los toques y el desplazamiento — no lo que está escrito en la pantalla.\nLa grabación nunca viene activada por defecto. Se te pregunta una vez y puedes retirar el permiso cuando quieras en Menú > Privacidad, lo que la detiene de inmediato. No se graba toda sesión: se graba una muestra, más las sesiones en las que la aplicación detecta que algo salió mal.",
    ),
    "privacyPoliceReplayTitle": MessageLookupByLibrary.simpleMessage(
      "Grabación de sesión",
    ),
    "privacyPoliceRetention": MessageLookupByLibrary.simpleMessage(
      "Tus servicios, clientes y ajustes se conservan mientras exista tu cuenta y se eliminan cuando pides la eliminación de la cuenta.\nLos eventos de uso y las grabaciones de sesión se conservan durante un periodo limitado por los proveedores de análisis y se eliminan automáticamente después. Los informes de fallos se conservan hasta 90 días.",
    ),
    "privacyPoliceRetentionTitle": MessageLookupByLibrary.simpleMessage(
      "Retención de datos",
    ),
    "privacyPoliceRights": MessageLookupByLibrary.simpleMessage(
      "Conforme a la Ley General de Protección de Datos de Brasil (LGPD, Ley 13.709/2018) y legislaciones equivalentes, tienes derecho a confirmar que tus datos se tratan, acceder a ellos, corregirlos, pedir su anonimización, bloqueo o eliminación, pedir portabilidad, saber con quién se comparten y oponerte al tratamiento basado en interés legítimo.\nLos dos interruptores en Menú > Privacidad te permiten ejercer el derecho de oposición directamente en la aplicación, sin pedírselo a nadie. Para cualquier otra cosa, escríbeme a la dirección de abajo y te respondo.",
    ),
    "privacyPoliceRightsTitle": MessageLookupByLibrary.simpleMessage(
      "Tus derechos",
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
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Política de privacidad",
    ),
    "privacySessionRecording": MessageLookupByLibrary.simpleMessage(
      "Grabación de sesión",
    ),
    "privacySessionRecordingDescription": MessageLookupByLibrary.simpleMessage(
      "Graba una repetición enmascarada de algunas sesiones. Todo el texto y las imágenes quedan ocultos.",
    ),
    "privacyUsageData": MessageLookupByLibrary.simpleMessage(
      "Ayudar a mejorar Kazi",
    ),
    "privacyUsageDataDescription": MessageLookupByLibrary.simpleMessage(
      "Envía eventos de uso anónimos para que yo descubra qué no funciona. Nunca tus importes ni tus clientes.",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("Perfil"),
    "quantity": MessageLookupByLibrary.simpleMessage("Cantidad"),
    "rateApp": MessageLookupByLibrary.simpleMessage("Calificar la app"),
    "ratesUnavailable": MessageLookupByLibrary.simpleMessage(
      "Tipos de cambio no disponibles",
    ),
    "ratesUnavailableDescription": MessageLookupByLibrary.simpleMessage(
      "Conéctate a internet para ver tus totales convertidos.",
    ),
    "received": MessageLookupByLibrary.simpleMessage("Recibido"),
    "receivedOn": m35,
    "removeFilters": MessageLookupByLibrary.simpleMessage("Eliminar filtros"),
    "replayConsentAccept": MessageLookupByLibrary.simpleMessage(
      "Permitir grabación",
    ),
    "replayConsentBody": MessageLookupByLibrary.simpleMessage(
      "Para descubrir qué te frena, Kazi puede grabar cómo recorres las pantallas — una repetición enmascarada, donde todo el texto y las imágenes quedan ocultos. Muestra dónde tocas y dónde te detienes, nunca lo que escribes.\n\nPuedes cambiar de opinión cuando quieras, en Menú > Privacidad.",
    ),
    "replayConsentDecline": MessageLookupByLibrary.simpleMessage("Ahora no"),
    "replayConsentTitle": MessageLookupByLibrary.simpleMessage(
      "¿Me ayudas a encontrar lo que estorba?",
    ),
    "requiredProperty": m36,
    "resendEmail": MessageLookupByLibrary.simpleMessage("Reenviar correo"),
    "resetedPassword": MessageLookupByLibrary.simpleMessage(
      "Contraseña restablecida con éxito",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Restaurar"),
    "restoredSnackbar": m37,
    "role": MessageLookupByLibrary.simpleMessage("Función"),
    "save": MessageLookupByLibrary.simpleMessage("Guardar"),
    "search": MessageLookupByLibrary.simpleMessage("Buscar"),
    "searchByName": MessageLookupByLibrary.simpleMessage("Buscar por nombre"),
    "selectCatalogItem": MessageLookupByLibrary.simpleMessage(
      "Selecciona el servicio",
    ),
    "selectClient": MessageLookupByLibrary.simpleMessage(
      "Selecciona el cliente",
    ),
    "selectCurrency": MessageLookupByLibrary.simpleMessage(
      "Selecciona una moneda",
    ),
    "sendEmail": MessageLookupByLibrary.simpleMessage("Enviar correo"),
    "service": MessageLookupByLibrary.simpleMessage("Servicio"),
    "serviceAdded": MessageLookupByLibrary.simpleMessage(
      "Servicio agregado con éxito",
    ),
    "serviceCatalog": MessageLookupByLibrary.simpleMessage(
      "Catálogo de servicios",
    ),
    "serviceDeleted": MessageLookupByLibrary.simpleMessage(
      "Servicio eliminado con éxito",
    ),
    "serviceUpdated": MessageLookupByLibrary.simpleMessage(
      "Servicio editado con éxito",
    ),
    "serviceValue": MessageLookupByLibrary.simpleMessage("Valor del servicio"),
    "services": MessageLookupByLibrary.simpleMessage("Servicios"),
    "servicesCount": m38,
    "settings": MessageLookupByLibrary.simpleMessage("Configuraciones"),
    "setupCatalogAddAnother": MessageLookupByLibrary.simpleMessage(
      "Agregar otro servicio",
    ),
    "setupCatalogBlankPrice": MessageLookupByLibrary.simpleMessage(
      "¿No sabes el precio? Déjalo en blanco: Kazi lo pregunta al registrar.",
    ),
    "setupCatalogContinueWith": m39,
    "setupCatalogDuplicate": MessageLookupByLibrary.simpleMessage(
      "Ya tienes un servicio con ese nombre.",
    ),
    "setupCatalogSubtitle": MessageLookupByLibrary.simpleMessage(
      "Desmarca lo que no hagas y toca el precio para poner el tuyo.",
    ),
    "setupCatalogTitle": MessageLookupByLibrary.simpleMessage(
      "¿Estos son los servicios que haces?",
    ),
    "setupCatalogTypedSubtitle": MessageLookupByLibrary.simpleMessage(
      "Empieza por el más común. Después puedes agregar los que quieras.",
    ),
    "setupCatalogTypedTitle": MessageLookupByLibrary.simpleMessage(
      "¿Qué servicios haces?",
    ),
    "setupCatalogYourPrices": MessageLookupByLibrary.simpleMessage(
      "Tus precios",
    ),
    "setupCommissionPerItem": MessageLookupByLibrary.simpleMessage(
      "Toca un servicio para cambiar solo ese.",
    ),
    "setupCommissionSubtitle": MessageLookupByLibrary.simpleMessage(
      "Es la comisión del salón. Si trabajas por tu cuenta, elige 100%.",
    ),
    "setupCommissionTitle": MessageLookupByLibrary.simpleMessage(
      "¿Cuánto te queda de cada servicio?",
    ),
    "setupContinue": MessageLookupByLibrary.simpleMessage("Continuar"),
    "setupCycleMonthlyDetail": m40,
    "setupCycleSubtitle": MessageLookupByLibrary.simpleMessage(
      "Kazi suma tus ganancias dentro de ese período.",
    ),
    "setupCycleTitle": MessageLookupByLibrary.simpleMessage("¿Cuándo cobras?"),
    "setupEmployed": MessageLookupByLibrary.simpleMessage(
      "Trabajo para un salón o empresa",
    ),
    "setupEmployedDetail": MessageLookupByLibrary.simpleMessage(
      "recibo comisión",
    ),
    "setupExitMessage": MessageLookupByLibrary.simpleMessage(
      "Lo que ya respondiste queda guardado. Puedes retomarlo desde la pantalla inicial.",
    ),
    "setupExitTitle": MessageLookupByLibrary.simpleMessage(
      "¿Salir de la configuración?",
    ),
    "setupFirstServiceOtherDay": MessageLookupByLibrary.simpleMessage(
      "Otro día",
    ),
    "setupFirstServicePastCycle": MessageLookupByLibrary.simpleMessage(
      "Este servicio entra en el ciclo anterior.",
    ),
    "setupFirstServiceRegister": MessageLookupByLibrary.simpleMessage(
      "Registrar",
    ),
    "setupFirstServiceSkip": MessageLookupByLibrary.simpleMessage(
      "Todavía no atendí, lo hago después",
    ),
    "setupFirstServiceSubtitle": MessageLookupByLibrary.simpleMessage(
      "Puede ser el de hoy. Toma 10 segundos.",
    ),
    "setupFirstServiceTitle": MessageLookupByLibrary.simpleMessage(
      "Vamos a registrar un servicio que ya hiciste.",
    ),
    "setupFirstServiceWhen": MessageLookupByLibrary.simpleMessage(
      "¿Cuándo fue?",
    ),
    "setupPriceSheetKeep": MessageLookupByLibrary.simpleMessage(
      "Cuánto te queda",
    ),
    "setupPriceSheetName": MessageLookupByLibrary.simpleMessage(
      "Nombre del servicio",
    ),
    "setupPriceSheetValue": MessageLookupByLibrary.simpleMessage(
      "Cuánto cobras",
    ),
    "setupProfessionField": MessageLookupByLibrary.simpleMessage("Profesión"),
    "setupProfessionNoMatch": MessageLookupByLibrary.simpleMessage(
      "¿No lo encontraste? Sigue escribiendo.",
    ),
    "setupProfessionSubtitle": MessageLookupByLibrary.simpleMessage(
      "Así Kazi ya empieza con tus servicios a tu medida.",
    ),
    "setupProfessionTitle": MessageLookupByLibrary.simpleMessage(
      "Antes de empezar, cuéntame qué haces.",
    ),
    "setupProfessionTypedSubtitle": MessageLookupByLibrary.simpleMessage(
      "Escríbelo a tu manera. Si lo conozco, ya te traigo una lista lista.",
    ),
    "setupProfessionTypedTitle": MessageLookupByLibrary.simpleMessage(
      "¿Qué haces?",
    ),
    "setupResultBreakdown": m41,
    "setupResultCta": MessageLookupByLibrary.simpleMessage("Ver mi Kazi"),
    "setupResultLabel": MessageLookupByLibrary.simpleMessage(
      "Servicio registrado",
    ),
    "setupResultReadySubtitle": MessageLookupByLibrary.simpleMessage(
      "En cuanto termines un servicio, toca la K en el centro de la barra.",
    ),
    "setupResultReadyTitle": MessageLookupByLibrary.simpleMessage(
      "Tu Kazi está listo.",
    ),
    "setupResultYours": MessageLookupByLibrary.simpleMessage("es tuyo"),
    "setupSelfEmployed": MessageLookupByLibrary.simpleMessage(
      "Trabajo por mi cuenta",
    ),
    "setupSelfEmployedDetail": MessageLookupByLibrary.simpleMessage(
      "me quedo con el 100%",
    ),
    "setupUnknownProfessionSubtitle": MessageLookupByLibrary.simpleMessage(
      "Sin problema: en un minuto Kazi lo aprende contigo. Primero, ¿cómo cobras?",
    ),
    "setupUnknownProfessionTitle": MessageLookupByLibrary.simpleMessage(
      "Todavía no conozco ese trabajo.",
    ),
    "share": MessageLookupByLibrary.simpleMessage("Compartir"),
    "signIn": MessageLookupByLibrary.simpleMessage("Ingresar"),
    "signOut": MessageLookupByLibrary.simpleMessage("Cerrar sesión"),
    "signOutConfirmation": MessageLookupByLibrary.simpleMessage(
      "¿Realmente deseas cerrar sesión?",
    ),
    "signOutStay": MessageLookupByLibrary.simpleMessage("Quedarme"),
    "signUp": MessageLookupByLibrary.simpleMessage("Registrarse"),
    "signUpSuccess": MessageLookupByLibrary.simpleMessage(
      "Registro realizado con éxito",
    ),
    "skip": MessageLookupByLibrary.simpleMessage("Omitir"),
    "splashSignature": MessageLookupByLibrary.simpleMessage("kazi · trabajo"),
    "summary": MessageLookupByLibrary.simpleMessage("Resumen"),
    "theme": MessageLookupByLibrary.simpleMessage("Tema"),
    "themeDark": MessageLookupByLibrary.simpleMessage("Oscuro"),
    "themeLight": MessageLookupByLibrary.simpleMessage("Claro"),
    "themeSystem": MessageLookupByLibrary.simpleMessage("Sistema"),
    "thisCatalogItem": MessageLookupByLibrary.simpleMessage("este servicio"),
    "thisClient": MessageLookupByLibrary.simpleMessage("este cliente"),
    "thisService": MessageLookupByLibrary.simpleMessage("este servicio"),
    "toReceive": m42,
    "today": MessageLookupByLibrary.simpleMessage("Hoy"),
    "todaySection": m43,
    "todaysServices": MessageLookupByLibrary.simpleMessage("Servicios de hoy"),
    "topClients": MessageLookupByLibrary.simpleMessage(
      "Clientes que más rindieron",
    ),
    "total": MessageLookupByLibrary.simpleMessage("Valor total"),
    "tourAppBarDescription": MessageLookupByLibrary.simpleMessage(
      "Aquí armas tu catálogo de servicios y cierras sesión.",
    ),
    "tourAppBarTitle": MessageLookupByLibrary.simpleMessage("Área del perfil"),
    "tourBottomNavigationServicesDescription": MessageLookupByLibrary.simpleMessage(
      "En este menú encontrarás todos los servicios realizados y podrás registrar uno nuevo.",
    ),
    "tourBottomNavigationServicesTitle": MessageLookupByLibrary.simpleMessage(
      "Área de servicios",
    ),
    "tourCatalogItemsDescription": MessageLookupByLibrary.simpleMessage(
      "Ponle nombre al servicio, como \"Pestañas - Volumen Brasileño\", y completa su valor predeterminado y la comisión que recibes por él.",
    ),
    "tourCatalogItemsTitle": MessageLookupByLibrary.simpleMessage("Catálogo"),
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
      "Aquí armas tu catálogo: los servicios que ofreces, con valor y comisión listos para cada registro.",
    ),
    "tourProfileTitle": MessageLookupByLibrary.simpleMessage("Acciones"),
    "tourServiceDetailsDescription": MessageLookupByLibrary.simpleMessage(
      "Al hacer clic en el servicio, puedes ver toda su información, editarlo o eliminarlo.",
    ),
    "tourServiceDetailsTitle": MessageLookupByLibrary.simpleMessage(
      "Detalles del servicio",
    ),
    "tourServicesForm1Description": MessageLookupByLibrary.simpleMessage(
      "Elige un servicio de tu catálogo y los valores se completan solos. Puedes ajustarlos solo en este registro.",
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
    "undo": MessageLookupByLibrary.simpleMessage("Deshacer"),
    "updateLater": MessageLookupByLibrary.simpleMessage("Más tarde"),
    "updateNow": MessageLookupByLibrary.simpleMessage("Actualizar"),
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
    "viewArchived": m44,
    "week": MessageLookupByLibrary.simpleMessage("Semana"),
    "whatsNewCatalog": MessageLookupByLibrary.simpleMessage(
      "Un catálogo listo por profesión, para quien está empezando.",
    ),
    "whatsNewCycle": MessageLookupByLibrary.simpleMessage(
      "Tu pantalla inicial ahora suma por el período en que realmente cobras.",
    ),
    "whatsNewSummary": MessageLookupByLibrary.simpleMessage(
      "Un resumen del mes, dentro de la pestaña Servicios.",
    ),
    "whatsNewTitle": MessageLookupByLibrary.simpleMessage("Qué cambió"),
    "withheld": MessageLookupByLibrary.simpleMessage("Retenido"),
    "withoutCatalogItem": MessageLookupByLibrary.simpleMessage(
      "Fuera del catálogo",
    ),
    "wouldYouLikeDelete": m45,
    "yesterday": MessageLookupByLibrary.simpleMessage("Ayer"),
    "yourEarnings": MessageLookupByLibrary.simpleMessage(
      "Tus ganancias de hoy",
    ),
  };
}
