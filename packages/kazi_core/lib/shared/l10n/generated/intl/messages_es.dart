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

  static String m2(version, year) => "Kazi ${version} · ${year}";

  static String m3(date) => "Archivado el ${date}";

  static String m4(name) => "${name} archivado.";

  static String m5(count) =>
      "${Intl.plural(count, one: 'Cierra en 1 día', other: 'Cierra en ${count} días')}";

  static String m6(day) => "Día ${day}";

  static String m7(count) =>
      "${Intl.plural(count, one: 'todos los días', other: 'cada ${count} días')}";

  static String m8(min, max) => "Ingresa entre ${min} y ${max} días";

  static String m9(range) => "Ciclo actual: ${range}";

  static String m10(start, end) => "${start} al ${end}";

  static String m11(name) => "¿Cancelar ${name}?";

  static String m12(date) => "Cancelado el ${date}";

  static String m13(count, amount) =>
      "${Intl.plural(count, one: 'Nombra 1 servicio ya registrado. Eliminarlo ahora dejaría ese registro sin identificación.', other: 'Nombra ${count} servicios ya registrados. Eliminarlo ahora dejaría esos registros sin identificación, y suman ${amount} en tu historial.')}";

  static String m14(name) => "${name} no se puede eliminar";

  static String m15(name) =>
      "\"${name}\" ya existe en tu catálogo, archivado. ¿Quieres restaurarlo?";

  static String m16(done, total) => "${done}/${total}";

  static String m17(count, name) =>
      "${Intl.plural(count, one: 'Ya existe ${name} con 1 servicio. Si es la misma persona, usa la que ya existe para no dividir el historial.', other: 'Ya existe ${name} con ${count} servicios. Si es la misma persona, usa la que ya existe para no dividir el historial.')}";

  static String m18(name, service, date) =>
      "Ya existe ${name}, atendido por última vez el ${date} para ${service}. Si es la misma persona, usa la que ya existe para no dividir el historial.";

  static String m19(name) =>
      "Ya existe ${name}. Si es la misma persona, usa la que ya existe para no dividir el historial.";

  static String m20(name) =>
      "Ya tienes un cliente con este documento: ${name}.";

  static String m21(name) =>
      "${name} ya está registrado con este documento, archivado. Restáuralo en vez de crear otro.";

  static String m22(month) => "cliente desde ${month}";

  static String m23(count) =>
      "${Intl.plural(count, one: '1 servicio del catálogo no tiene comisión', other: '${count} servicios del catálogo no tienen comisión')}";

  static String m24(percent, amount) => "${percent} de ${amount}";

  static String m25(percent) => "Comisión ${percent}";

  static String m26(percent, amount) =>
      "${percent} de ${amount} cobrados a los clientes";

  static String m27(percent, amount) => "${percent} de ${amount} generados";

  static String m28(term) => "Crear “${term}” en el catálogo";

  static String m29(days) =>
      "${Intl.plural(days, zero: 'cierra hoy', one: 'cierra mañana', other: 'cierra en ${days} días')}";

  static String m30(count) =>
      "${Intl.plural(count, one: 'El servicio ya realizado sigue en el historial. Solo se borran los datos de contacto. Esta acción no tiene vuelta atrás.', other: 'Los ${count} servicios ya realizados siguen en el historial. Solo se borran los datos de contacto. Esta acción no tiene vuelta atrás.')}";

  static String m31(name) => "¿Eliminar ${name} para siempre?";

  static String m32(latest, current) =>
      "Versión ${latest} · estás en ${current}";

  static String m33(count) => "${count} servicios en el catálogo";

  static String m34(count) => "${count} clientes";

  static String m35(count) => "${count} servicios / mes";

  static String m36(start, end) => "Desde ${start} hasta ${end}";

  static String m37(amount) => "de ${amount} generados";

  static String m38(amount) => "de ${amount} cobrados a los clientes";

  static String m39(property) => "${property} está vacío";

  static String m40(count) =>
      "${Intl.plural(count, one: '1 ítem', other: '${count} ítems')}";

  static String m41(date) => "Último el ${date}";

  static String m42(privacy) => "Al continuar, aceptas la ${privacy}.";

  static String m43(count) =>
      "${Intl.plural(count, one: 'Marcar el 1 pendiente como recibido', other: 'Marcar los ${count} pendientes como recibidos')}";

  static String m44(amount) =>
      "Son ${amount} en total. Esto no cambia los valores ni las fechas: solo registra que el pago entró.";

  static String m45(count) =>
      "${Intl.plural(count, one: '¿Marcar 1 servicio como recibido?', other: '¿Marcar ${count} servicios como recibidos?')}";

  static String m46(count) =>
      "${Intl.plural(count, one: 'El 1 servicio que ya estaba recibido no se toca.', other: 'Los ${count} servicios que ya estaban recibidos no se tocan.')}";

  static String m47(term) => "No se encontró nada para “${term}”";

  static String m48(amount) => "de ${amount}";

  static String m49(price) => "${price}/mes";

  static String m50(price) => "7 días gratis, luego ${price}/mes.";

  static String m51(amount) => "${amount} pendientes";

  static String m52(period) => "${period} · tu ganancia";

  static String m53(count) =>
      "${Intl.plural(count, one: 'Cambiar el precio aquí vale para los próximos registros. El servicio ya registrado mantiene el valor de su época.', other: 'Cambiar el precio aquí vale para los próximos registros. Los ${count} servicios ya registrados mantienen el valor de su época.')}";

  static String m54(date) => "Actualizada el ${date}";

  static String m55(date) => "Recibido el ${date}";

  static String m56(name, email, uid) =>
      "Hola, soy el usuario ${name} (${email} · ${uid}) y me gustaría reportar el siguiente problema: ";

  static String m57(property) => "${property} debe ser completado";

  static String m58(count, amount) =>
      "${Intl.plural(count, one: '1 servicio', other: '${count} servicios')} · ${amount} para ti";

  static String m59(count) =>
      "${Intl.plural(count, zero: 'Ningún servicio', one: 'Ver 1 servicio', other: 'Ver ${count} servicios')}";

  static String m60(count) =>
      "${Intl.plural(count, one: 'Ver el 1 servicio', other: 'Ver los ${count} servicios')}";

  static String m61(count) =>
      "${Intl.plural(count, one: '1 servicio', other: '${count} servicios')}";

  static String m62(count) => "Continuar con ${count}";

  static String m63(day) => "día ${day}";

  static String m64(total, percent) => "de ${total} · comisión del ${percent}";

  static String m65(count) => "Ver todos (${count})";

  static String m66(count) =>
      "${Intl.plural(count, one: 'Hoy · 1 servicio', other: 'Hoy · ${count} servicios')}";

  static String m67(name) => "Usar ${name} que ya existe";

  static String m68(count) =>
      "${Intl.plural(count, one: 'usado en 1 servicio', other: 'usado en ${count} servicios')}";

  static String m69(count) =>
      "${Intl.plural(count, one: '1 uso', other: '${count} usos')}";

  static String m70(count) => "Ver archivados · ${count}";

  static String m71(version) => "Versión ${version}";

  static String m72(amount) => "${amount} son tuyos";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("Soporte"),
        "actions": MessageLookupByLibrary.simpleMessage("Acciones"),
        "addClient": MessageLookupByLibrary.simpleMessage("Agregar cliente"),
        "address": MessageLookupByLibrary.simpleMessage("Dirección"),
        "allClients":
            MessageLookupByLibrary.simpleMessage("Todos los clientes"),
        "allReceipts": MessageLookupByLibrary.simpleMessage("Todas"),
        "alreadyExists": m0,
        "alreadyReceived": m1,
        "amount": MessageLookupByLibrary.simpleMessage("Valor"),
        "appVersionFooter": m2,
        "applyFilters": MessageLookupByLibrary.simpleMessage("Aplicar filtros"),
        "archive": MessageLookupByLibrary.simpleMessage("Archivar"),
        "archivedCatalogItems": MessageLookupByLibrary.simpleMessage(
          "Catálogo archivado",
        ),
        "archivedCatalogNote": MessageLookupByLibrary.simpleMessage(
          "Los elementos del catálogo archivados no aparecen al registrar un servicio, pero siguen nombrando los servicios en los que ya se usaron.",
        ),
        "archivedClients": MessageLookupByLibrary.simpleMessage(
          "Clientes archivados",
        ),
        "archivedClientsNote": MessageLookupByLibrary.simpleMessage(
          "Un cliente archivado desaparece de las búsquedas y del formulario, pero sigue en el historial de los servicios ya registrados.",
        ),
        "archivedOn": m3,
        "archivedSectionLabel":
            MessageLookupByLibrary.simpleMessage("Archivados"),
        "archivedSnackbar": m4,
        "attention": MessageLookupByLibrary.simpleMessage("Atención"),
        "back": MessageLookupByLibrary.simpleMessage("Volver"),
        "billingCycle": MessageLookupByLibrary.simpleMessage("Ciclo de pago"),
        "billingCycleClosesInDays": m5,
        "billingCycleCustom":
            MessageLookupByLibrary.simpleMessage("Personalizado"),
        "billingCycleCustomAnchorDate": MessageLookupByLibrary.simpleMessage(
          "Un día en que cobras",
        ),
        "billingCycleCustomAnchorHint": MessageLookupByLibrary.simpleMessage(
          "Tu último o tu próximo cobro. Kazi repite el ciclo a partir de él.",
        ),
        "billingCycleDay": m6,
        "billingCycleDescription": MessageLookupByLibrary.simpleMessage(
          "Kazi suma tus ganancias dentro de ese período. Es lo que define el número grande del Inicio.",
        ),
        "billingCycleFortnightly": MessageLookupByLibrary.simpleMessage(
          "Quincenal",
        ),
        "billingCycleFrequency": m7,
        "billingCycleIntervalDays": MessageLookupByLibrary.simpleMessage(
          "Cada cuántos días",
        ),
        "billingCycleIntervalError": m8,
        "billingCycleLastDay":
            MessageLookupByLibrary.simpleMessage("Último día"),
        "billingCycleMonthly": MessageLookupByLibrary.simpleMessage("Mensual"),
        "billingCycleOther": MessageLookupByLibrary.simpleMessage("Otro"),
        "billingCyclePayday": MessageLookupByLibrary.simpleMessage(
          "Día en que cobro",
        ),
        "billingCyclePayoutDayGroup": MessageLookupByLibrary.simpleMessage(
          "Cobras el día",
        ),
        "billingCyclePreview": m9,
        "billingCycleRange": m10,
        "billingCycleSave":
            MessageLookupByLibrary.simpleMessage("Guardar ciclo"),
        "billingCycleWeekly": MessageLookupByLibrary.simpleMessage("Semanal"),
        "birthDate": MessageLookupByLibrary.simpleMessage("Cumpleaños"),
        "byCatalogItem": MessageLookupByLibrary.simpleMessage("Por servicio"),
        "call": MessageLookupByLibrary.simpleMessage("Llamar"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "cancelService":
            MessageLookupByLibrary.simpleMessage("Cancelar servicio"),
        "cancelServiceImpact": MessageLookupByLibrary.simpleMessage(
          "Se queda en tu historial marcado como cancelado, y sale de tus totales. Puedes reabrirlo cuando quieras.",
        ),
        "cancelServiceTitle": m11,
        "cancelledOn": m12,
        "cancelledPlural": MessageLookupByLibrary.simpleMessage("Cancelados"),
        "cantDeleteBody": m13,
        "cantDeleteReassurance": MessageLookupByLibrary.simpleMessage(
          "Archivado ya basta: el ítem ya no aparece cuando registras un servicio nuevo.",
        ),
        "cantDeleteTitle": m14,
        "catalogAll": MessageLookupByLibrary.simpleMessage("Todos"),
        "catalogItem": MessageLookupByLibrary.simpleMessage("Servicio"),
        "catalogItemArchivedRestorePrompt": m15,
        "catalogItemDuplicateName": MessageLookupByLibrary.simpleMessage(
          "Ya existe un elemento con este nombre. Usa otro nombre o edita el que existe.",
        ),
        "catalogItemFormHint": MessageLookupByLibrary.simpleMessage(
          "El precio y la comisión vienen del catálogo. Puedes cambiarlos solo en este registro.",
        ),
        "catalogItems": MessageLookupByLibrary.simpleMessage("Catálogo"),
        "catalogMostUsed": MessageLookupByLibrary.simpleMessage("Más usados"),
        "catalogWithoutCommission": MessageLookupByLibrary.simpleMessage(
          "Sin comisión",
        ),
        "checklistBuildCatalog": MessageLookupByLibrary.simpleMessage(
          "Armar tu catálogo",
        ),
        "checklistFirstService": MessageLookupByLibrary.simpleMessage(
          "Registrar el primer servicio",
        ),
        "checklistMarkReceived": MessageLookupByLibrary.simpleMessage(
          "Marcar un servicio como recibido",
        ),
        "checklistProgress": m16,
        "checklistSeeSummary": MessageLookupByLibrary.simpleMessage(
          "Ver el resumen de tu mes",
        ),
        "checklistThreeServices": MessageLookupByLibrary.simpleMessage(
          "Registrar 3 servicios seguidos",
        ),
        "checklistTitle": MessageLookupByLibrary.simpleMessage(
          "Deja Kazi a tu manera",
        ),
        "clear": MessageLookupByLibrary.simpleMessage("Limpiar"),
        "clearAll": MessageLookupByLibrary.simpleMessage("Limpiar todo"),
        "client": MessageLookupByLibrary.simpleMessage("Cliente"),
        "clientFormHint": MessageLookupByLibrary.simpleMessage(
          "Opcional. Sirve para el historial y el resumen por cliente.",
        ),
        "clientNamesake": m17,
        "clientNamesakeLastService": m18,
        "clientNamesakePlain": m19,
        "clientSameDocument": m20,
        "clientSameDocumentArchived": m21,
        "clientSince": m22,
        "clients": MessageLookupByLibrary.simpleMessage("Clientes"),
        "clientsTipDescription": MessageLookupByLibrary.simpleMessage(
          "Da seguimiento a tus clientes y entrega un trabajo excelente.",
        ),
        "clientsTipTitle": MessageLookupByLibrary.simpleMessage(
          "Las buenas relaciones generan más oportunidades.",
        ),
        "close": MessageLookupByLibrary.simpleMessage("Cerrar"),
        "color": MessageLookupByLibrary.simpleMessage("Color"),
        "colorSwipeAll": MessageLookupByLibrary.simpleMessage(
          "Color · desliza para ver todos",
        ),
        "commission": MessageLookupByLibrary.simpleMessage("Comisión"),
        "commissionGapsBody": MessageLookupByLibrary.simpleMessage(
          "Sin eso entran en el total generado, pero no en lo que recibes.",
        ),
        "commissionGapsCta": MessageLookupByLibrary.simpleMessage(
          "Definir ahora · 30 seg",
        ),
        "commissionGapsTitle": m23,
        "commissionOfGross": m24,
        "commissionPercent": m25,
        "commissionShareOfCharged": m26,
        "commissionShareOfGenerated": m27,
        "confirm": MessageLookupByLibrary.simpleMessage("Confirmar"),
        "contact": MessageLookupByLibrary.simpleMessage("Contacto"),
        "contactEmail":
            MessageLookupByLibrary.simpleMessage("contact@kazipro.io"),
        "contactOptionsTitle": MessageLookupByLibrary.simpleMessage(
          "Ponerse en contacto",
        ),
        "continueAction": MessageLookupByLibrary.simpleMessage("Continuar"),
        "continueWithGoogle": MessageLookupByLibrary.simpleMessage(
          "Continuar con Google",
        ),
        "copyNumber": MessageLookupByLibrary.simpleMessage("Copiar número"),
        "createAndUse": MessageLookupByLibrary.simpleMessage("Crear y usar"),
        "createAnyway": MessageLookupByLibrary.simpleMessage(
          "Crear de todos modos",
        ),
        "createInCatalog": m28,
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
        "currencyCRC":
            MessageLookupByLibrary.simpleMessage("Colón costarricense"),
        "currencyCUP": MessageLookupByLibrary.simpleMessage("Peso cubano"),
        "currencyChangeNote": MessageLookupByLibrary.simpleMessage(
          "Cambiar la moneda cambia el símbolo y el formato. Los valores ya registrados no se convierten.",
        ),
        "currencyChangeNoteEmphasis": MessageLookupByLibrary.simpleMessage(
          "no se convierten",
        ),
        "currencyDOP": MessageLookupByLibrary.simpleMessage("Peso dominicano"),
        "currencyETB": MessageLookupByLibrary.simpleMessage("Birr etíope"),
        "currencyEUR": MessageLookupByLibrary.simpleMessage("Euro"),
        "currencyGBP": MessageLookupByLibrary.simpleMessage("Libra esterlina"),
        "currencyGHS": MessageLookupByLibrary.simpleMessage("Cedi ghanés"),
        "currencyGTQ":
            MessageLookupByLibrary.simpleMessage("Quetzal guatemalteco"),
        "currencyHNL":
            MessageLookupByLibrary.simpleMessage("Lempira hondureña"),
        "currencyHTG": MessageLookupByLibrary.simpleMessage("Gourde haitiano"),
        "currencyINR": MessageLookupByLibrary.simpleMessage("Rupia india"),
        "currencyJPY": MessageLookupByLibrary.simpleMessage("Yen japonés"),
        "currencyKES": MessageLookupByLibrary.simpleMessage("Chelín keniano"),
        "currencyKRW": MessageLookupByLibrary.simpleMessage("Won surcoreano"),
        "currencyMAD": MessageLookupByLibrary.simpleMessage("Dírham marroquí"),
        "currencyMXN": MessageLookupByLibrary.simpleMessage("Peso mexicano"),
        "currencyNGN": MessageLookupByLibrary.simpleMessage("Naira nigeriana"),
        "currencyNIO":
            MessageLookupByLibrary.simpleMessage("Córdoba nicaragüense"),
        "currencyPAB": MessageLookupByLibrary.simpleMessage("Balboa panameño"),
        "currencyPEN": MessageLookupByLibrary.simpleMessage("Sol peruano"),
        "currencyPYG":
            MessageLookupByLibrary.simpleMessage("Guaraní paraguayo"),
        "currencyRUB": MessageLookupByLibrary.simpleMessage("Rublo ruso"),
        "currencySAR": MessageLookupByLibrary.simpleMessage("Riyal saudí"),
        "currencySGD":
            MessageLookupByLibrary.simpleMessage("Dólar de Singapur"),
        "currencyTRY": MessageLookupByLibrary.simpleMessage("Lira turca"),
        "currencyUGX": MessageLookupByLibrary.simpleMessage("Chelín ugandés"),
        "currencyUSD":
            MessageLookupByLibrary.simpleMessage("Dólar estadounidense"),
        "currencyUYU": MessageLookupByLibrary.simpleMessage("Peso uruguayo"),
        "currencyVES":
            MessageLookupByLibrary.simpleMessage("Bolívar venezolano"),
        "currencyXAF": MessageLookupByLibrary.simpleMessage(
          "Franco CFA de África Central",
        ),
        "currencyXOF": MessageLookupByLibrary.simpleMessage(
          "Franco CFA de África Occidental",
        ),
        "currencyZAR": MessageLookupByLibrary.simpleMessage("Rand sudafricano"),
        "currentCycle": MessageLookupByLibrary.simpleMessage("Ciclo actual"),
        "cycleClosesIn": m29,
        "date": MessageLookupByLibrary.simpleMessage("Fecha"),
        "defaultCurrency": MessageLookupByLibrary.simpleMessage(
          "Moneda predeterminada",
        ),
        "defaultPrice": MessageLookupByLibrary.simpleMessage("Precio estándar"),
        "delete": MessageLookupByLibrary.simpleMessage("Eliminar"),
        "deleteClientImpact": m30,
        "deleteForeverTitle": m31,
        "deleteNoServicesImpact": MessageLookupByLibrary.simpleMessage(
          "No aparece en ningún servicio, así que nada de tu historial cambia. Esta acción no tiene vuelta atrás.",
        ),
        "deletePermanently": MessageLookupByLibrary.simpleMessage(
          "Eliminar definitivamente",
        ),
        "deleteServiceImpact": MessageLookupByLibrary.simpleMessage(
          "El registro sale del historial y de los totales. Esta acción no tiene vuelta atrás.",
        ),
        "description": MessageLookupByLibrary.simpleMessage("Descripción"),
        "details": MessageLookupByLibrary.simpleMessage("Detalles"),
        "document": MessageLookupByLibrary.simpleMessage("Documento"),
        "documentHint": MessageLookupByLibrary.simpleMessage(
          "CUIT, RUC, DNI u otro",
        ),
        "documentPrivacyHint": MessageLookupByLibrary.simpleMessage(
          "Solo para que identifiques a la persona y emitas recibos. Kazi no valida ese número ni lo envía a ninguna parte.",
        ),
        "earnedYou": MessageLookupByLibrary.simpleMessage("Generó para ti"),
        "earningsChartHint": MessageLookupByLibrary.simpleMessage(
          "Toca o desliza por el gráfico para ver las ganancias de cada día",
        ),
        "earningsPerWeek": MessageLookupByLibrary.simpleMessage(
          "tu ganancia por semana",
        ),
        "earningsThisCycle": MessageLookupByLibrary.simpleMessage(
          "Tus ganancias este ciclo",
        ),
        "earningsThisFortnight": MessageLookupByLibrary.simpleMessage(
          "Tus ganancias esta quincena",
        ),
        "earningsThisMonth": MessageLookupByLibrary.simpleMessage(
          "Tus ganancias este mes",
        ),
        "earningsThisWeek": MessageLookupByLibrary.simpleMessage(
          "Tus ganancias esta semana",
        ),
        "edit": MessageLookupByLibrary.simpleMessage("Editar"),
        "editService": MessageLookupByLibrary.simpleMessage("Editar servicio"),
        "email": MessageLookupByLibrary.simpleMessage("Email"),
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
        "errorDataIsSafe": MessageLookupByLibrary.simpleMessage(
          "Tus datos están guardados: solo inténtalo de nuevo.",
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
        "errorMethodNotAllowed": MessageLookupByLibrary.simpleMessage(
          "Método no permitido. Intenta con otra cuenta o contacta al soporte para obtener ayuda.",
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
        "errorToCancelService": MessageLookupByLibrary.simpleMessage(
          "Error al cancelar el servicio.",
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
        "errorToOpenApp": MessageLookupByLibrary.simpleMessage(
          "No se pudo abrir la aplicación.",
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
        "errorToUpdateCatalogItem": MessageLookupByLibrary.simpleMessage(
          "Error al editar el servicio del catálogo.",
        ),
        "errorToUpdateClient": MessageLookupByLibrary.simpleMessage(
          "Error al actualizar cliente.",
        ),
        "errorToUpdateService": MessageLookupByLibrary.simpleMessage(
          "Error al editar el servicio.",
        ),
        "errorToVerifyDocument": MessageLookupByLibrary.simpleMessage(
          "No se pudo verificar si este documento ya está registrado. Inténtalo de nuevo.",
        ),
        "errorTokenExpired": MessageLookupByLibrary.simpleMessage(
          "Tu sesión expiró. Por favor, inicia sesión e inténtalo de nuevo.",
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
        "filteringLastMonth": MessageLookupByLibrary.simpleMessage(
          "Filtrando por el mes pasado",
        ),
        "filters": MessageLookupByLibrary.simpleMessage("Filtros"),
        "finish": MessageLookupByLibrary.simpleMessage("Finalizar"),
        "forcedUpdateButton": MessageLookupByLibrary.simpleMessage(
          "Actualizar ahora",
        ),
        "forcedUpdateMessage": MessageLookupByLibrary.simpleMessage(
          "Actualiza para continuar: tus datos están guardados y aparecen en cuanto abras la app.",
        ),
        "forcedUpdateTitle": MessageLookupByLibrary.simpleMessage(
          "Esta versión de Kazi dejó de funcionar",
        ),
        "forcedUpdateVersions": m32,
        "fortnight": MessageLookupByLibrary.simpleMessage("15 días"),
        "freeLimitAds": MessageLookupByLibrary.simpleMessage("Con anuncios"),
        "freeLimitCatalogItems": m33,
        "freeLimitClients": m34,
        "freeLimitServices": m35,
        "freePlan": MessageLookupByLibrary.simpleMessage("Gratis"),
        "freeToDelete": MessageLookupByLibrary.simpleMessage("libre"),
        "fromTo": m36,
        "generatedFromAmount": m37,
        "generatedFromClients": m38,
        "generatedSoFar":
            MessageLookupByLibrary.simpleMessage("Generó hasta hoy"),
        "hintFabBody": MessageLookupByLibrary.simpleMessage(
          "Cada vez que termines un servicio, toca la K en el centro de la barra. Elige el servicio, confirma y listo.",
        ),
        "hintFabTitle": MessageLookupByLibrary.simpleMessage(
          "Aquí es donde registras",
        ),
        "hintFiltersBody": MessageLookupByLibrary.simpleMessage(
          "Con algo de historial, los filtros encuentran un cliente, un período o un servicio.",
        ),
        "hintFiltersTitle":
            MessageLookupByLibrary.simpleMessage("Filtra la lista"),
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
        "history": MessageLookupByLibrary.simpleMessage("Historial"),
        "home": MessageLookupByLibrary.simpleMessage("Inicio"),
        "howToUseClientEarningsBody": MessageLookupByLibrary.simpleMessage(
          "Abre un cliente y toca \"Ver en el resumen\" para saber cuánto generó y cuánto recibiste.",
        ),
        "howToUseClientEarningsTitle": MessageLookupByLibrary.simpleMessage(
          "Ve cuánto rinde cada cliente",
        ),
        "howToUseCloseCycleBody": MessageLookupByLibrary.simpleMessage(
          "En el encabezado de Servicios, marca todo lo pendiente como recibido de una vez.",
        ),
        "howToUseCloseCycleTitle": MessageLookupByLibrary.simpleMessage(
          "Cierra todo el período de una vez",
        ),
        "howToUseKazi": MessageLookupByLibrary.simpleMessage("Cómo usar Kazi"),
        "howToUseStartBody": MessageLookupByLibrary.simpleMessage(
          "El botón amarillo en el centro de la barra abre la pantalla para registrar un servicio.",
        ),
        "howToUseStartHere": MessageLookupByLibrary.simpleMessage(
          "Empieza por aquí",
        ),
        "howToUseStartTitle": MessageLookupByLibrary.simpleMessage(
          "Registrar un servicio",
        ),
        "howToUseStatusBody": MessageLookupByLibrary.simpleMessage(
          "Abre el servicio: el botón al pie lo marca como recibido y los tres puntos lo cancelan. La edición también cambia la situación.",
        ),
        "howToUseStatusTitle": MessageLookupByLibrary.simpleMessage(
          "Cambiar la situación de un servicio",
        ),
        "invalidIntNumber": MessageLookupByLibrary.simpleMessage(
          "Por favor, ingresa un número entero válido",
        ),
        "invalidNumber": MessageLookupByLibrary.simpleMessage(
          "Por favor, ingresa un número válido",
        ),
        "isEmpty": m39,
        "itemsCount": m40,
        "kaziProActive": MessageLookupByLibrary.simpleMessage("Activo"),
        "kaziProDescription": MessageLookupByLibrary.simpleMessage(
          "Más herramientas. Más oportunidades.",
        ),
        "kaziProTitle": MessageLookupByLibrary.simpleMessage("Kazi Pro"),
        "language": MessageLookupByLibrary.simpleMessage("Idioma"),
        "lastServiceOn": m41,
        "leaveApp": MessageLookupByLibrary.simpleMessage(
          "¿Realmente deseas salir de la aplicación?",
        ),
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
        "loginLegal": m42,
        "loginSubtitle": MessageLookupByLibrary.simpleMessage(
          "Entra para ver cuánto generas y cuánto recibes.",
        ),
        "markAsReceived": MessageLookupByLibrary.simpleMessage(
          "Marcar como recibido",
        ),
        "markListedReceived": m43,
        "markListedReceivedBody": m44,
        "markListedReceivedConfirm": m45,
        "markListedReceivedUntouched": m46,
        "markReceived": MessageLookupByLibrary.simpleMessage("Marcar recibido"),
        "markedAsReceived": MessageLookupByLibrary.simpleMessage(
          "Marcados como recibidos",
        ),
        "mostGets": MessageLookupByLibrary.simpleMessage("Más hace"),
        "myWork": MessageLookupByLibrary.simpleMessage("Herramientas"),
        "name": MessageLookupByLibrary.simpleMessage("Nombre"),
        "newCatalogItem":
            MessageLookupByLibrary.simpleMessage("Nuevo servicio"),
        "newClient": MessageLookupByLibrary.simpleMessage("Nuevo cliente"),
        "newService": MessageLookupByLibrary.simpleMessage("Nuevo servicio"),
        "newShort": MessageLookupByLibrary.simpleMessage("+ Nuevo"),
        "noCatalogItems": MessageLookupByLibrary.simpleMessage(
          "Tu catálogo está vacío. Toca el botón de arriba para agregar el primer servicio.",
        ),
        "noCatalogItemsDescription": MessageLookupByLibrary.simpleMessage(
          "Registra lo que haces y por cuánto.",
        ),
        "noClientsDescription": MessageLookupByLibrary.simpleMessage(
          "Se crean solos a medida que registras servicios. O agrega el primero ahora.",
        ),
        "noClientsFound": MessageLookupByLibrary.simpleMessage(
          "No se encontraron clientes",
        ),
        "noColor": MessageLookupByLibrary.simpleMessage("Sin color"),
        "noResults": MessageLookupByLibrary.simpleMessage("Sin resultados"),
        "noServiceForThisClient": MessageLookupByLibrary.simpleMessage(
          "Ningún servicio registrado para esta persona todavía.",
        ),
        "noServiceYet": MessageLookupByLibrary.simpleMessage(
          "Ningún servicio todavía",
        ),
        "noServices": MessageLookupByLibrary.simpleMessage("Ningún servicio"),
        "noServicesForFilters": MessageLookupByLibrary.simpleMessage(
          "Ningún servicio coincide con estos filtros.",
        ),
        "noServicesFound": MessageLookupByLibrary.simpleMessage(
          "Ningún servicio encontrado.",
        ),
        "noServicesToday": MessageLookupByLibrary.simpleMessage(
          "Ningún servicio registrado hoy",
        ),
        "noServicesYet": MessageLookupByLibrary.simpleMessage(
          "Todavía no hay servicios",
        ),
        "noServicesYetDescription": MessageLookupByLibrary.simpleMessage(
          "Registra tu primer servicio para empezar a seguir tus ganancias.",
        ),
        "nothingFoundFor": m47,
        "nothingFoundForDescription": MessageLookupByLibrary.simpleMessage(
          "Ningún servicio, cliente o ítem del catálogo con ese nombre.",
        ),
        "nothingFoundInCatalog": MessageLookupByLibrary.simpleMessage(
          "Ningún elemento del catálogo con ese nombre.",
        ),
        "numberBiggerThan100": MessageLookupByLibrary.simpleMessage(
          "Por favor, ingresa un número menor o igual a 100",
        ),
        "numberCopied": MessageLookupByLibrary.simpleMessage("Número copiado"),
        "numberLesserThanZero": MessageLookupByLibrary.simpleMessage(
          "Por favor, ingresa un número mayor o igual a cero",
        ),
        "observation": MessageLookupByLibrary.simpleMessage("Observación"),
        "observationHint": MessageLookupByLibrary.simpleMessage(
          "Alergia, preferencia, horario",
        ),
        "ofGross": m48,
        "optional": MessageLookupByLibrary.simpleMessage("opcional"),
        "optionalUpdateMessage": MessageLookupByLibrary.simpleMessage(
          "Hay una nueva versión de Kazi disponible con mejoras. ¿Deseas actualizar ahora?",
        ),
        "optionalUpdateTitle": MessageLookupByLibrary.simpleMessage(
          "Actualización disponible",
        ),
        "orderAlphabetical": MessageLookupByLibrary.simpleMessage("A–Z"),
        "orderBy": MessageLookupByLibrary.simpleMessage("Ordenar por"),
        "orderDateAsc": MessageLookupByLibrary.simpleMessage("Más antiguos"),
        "orderDateDesc": MessageLookupByLibrary.simpleMessage("Más recientes"),
        "orderLastService":
            MessageLookupByLibrary.simpleMessage("Último servicio"),
        "orderTopEarning":
            MessageLookupByLibrary.simpleMessage("Más rindieron"),
        "orderValueAsc": MessageLookupByLibrary.simpleMessage("Menor valor"),
        "orderValueDesc": MessageLookupByLibrary.simpleMessage("Mayor valor"),
        "paywallPricePerMonth": m49,
        "paywallRenewInfo": MessageLookupByLibrary.simpleMessage(
          "Se renueva automáticamente cada mes. Cancela cuando quieras.",
        ),
        "paywallRestore":
            MessageLookupByLibrary.simpleMessage("Restaurar compra"),
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
        "paywallTrialThenPrice": m50,
        "pendingAmount": m51,
        "pendingReceipt": MessageLookupByLibrary.simpleMessage("Pendientes"),
        "period": MessageLookupByLibrary.simpleMessage("Período"),
        "periodYourEarnings": m52,
        "phone": MessageLookupByLibrary.simpleMessage("Teléfono"),
        "phoneHint":
            MessageLookupByLibrary.simpleMessage("Para llamar después"),
        "pickDate": MessageLookupByLibrary.simpleMessage("Elegir"),
        "pickDates": MessageLookupByLibrary.simpleMessage("Elegir fechas"),
        "preferences": MessageLookupByLibrary.simpleMessage("Preferencias"),
        "premiumPlan": MessageLookupByLibrary.simpleMessage("Premium"),
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
        "presetDesign":
            MessageLookupByLibrary.simpleMessage("Diseño y creación"),
        "presetDesignBrandIdentity": MessageLookupByLibrary.simpleMessage(
          "Identidad visual",
        ),
        "presetDesignHourly":
            MessageLookupByLibrary.simpleMessage("Hora suelta"),
        "presetDesignLandingPage": MessageLookupByLibrary.simpleMessage(
          "Landing page",
        ),
        "presetDesignLogo": MessageLookupByLibrary.simpleMessage("Logo"),
        "presetDesignSocialPost": MessageLookupByLibrary.simpleMessage(
          "Post para redes sociales",
        ),
        "presetEsthetics":
            MessageLookupByLibrary.simpleMessage("Estética y cejas"),
        "presetEstheticsBrowDesign": MessageLookupByLibrary.simpleMessage(
          "Diseño de cejas",
        ),
        "presetEstheticsBrowHenna": MessageLookupByLibrary.simpleMessage(
          "Diseño de cejas con henna",
        ),
        "presetEstheticsFacialCleansing": MessageLookupByLibrary.simpleMessage(
          "Limpieza facial",
        ),
        "presetEstheticsFullLegWax": MessageLookupByLibrary.simpleMessage(
          "Depilación de pierna entera",
        ),
        "presetEstheticsLashExtensions": MessageLookupByLibrary.simpleMessage(
          "Extensión de pestañas",
        ),
        "presetEstheticsPeeling":
            MessageLookupByLibrary.simpleMessage("Peeling"),
        "presetEstheticsUnderarmWax": MessageLookupByLibrary.simpleMessage(
          "Depilación de axilas",
        ),
        "presetEstheticsUpperLipWax": MessageLookupByLibrary.simpleMessage(
          "Depilación de bozo",
        ),
        "presetHair":
            MessageLookupByLibrary.simpleMessage("Peluquería y barbería"),
        "presetHairBeard": MessageLookupByLibrary.simpleMessage("Barba"),
        "presetHairBlowDry": MessageLookupByLibrary.simpleMessage("Brushing"),
        "presetHairColoring":
            MessageLookupByLibrary.simpleMessage("Coloración"),
        "presetHairConditioning": MessageLookupByLibrary.simpleMessage(
          "Hidratación capilar",
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
          "Esmaltado de manos y pies",
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
        "presetMassage":
            MessageLookupByLibrary.simpleMessage("Masaje y bienestar"),
        "presetMassageContouring": MessageLookupByLibrary.simpleMessage(
          "Masaje modelador",
        ),
        "presetMassageHotStone": MessageLookupByLibrary.simpleMessage(
          "Masaje con piedras calientes",
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
        "priceChangeNote": m53,
        "privacy": MessageLookupByLibrary.simpleMessage("Privacidad"),
        "privacyOpenWebVersion": MessageLookupByLibrary.simpleMessage(
          "Abrir en la web",
        ),
        "privacyPoliceAnalytics": MessageLookupByLibrary.simpleMessage(
          "Para entender dónde estorba la aplicación y por qué la gente deja de usarla, recojo eventos de uso: qué pantallas abres, qué acciones completas, qué errores se te muestran y atributos técnicos como la versión de la app, el idioma y el tipo de dispositivo.\nEstos eventos describen comportamiento, nunca contenido. Jamás llevan los importes que registras, los nombres de tus clientes, tu correo electrónico ni ningún texto libre que escribas: la aplicación los elimina antes de enviar nada.\nLa base legal es mi interés legítimo en mejorar el Servicio, y puedes oponerte en cualquier momento en Menú > Privacidad.\nEncargados: Google Firebase Analytics (Google LLC) y PostHog (PostHog, Inc.), cuyos datos de esta aplicación se alojan en la Unión Europea.",
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
        "privacyPoliceInformation": MessageLookupByLibrary.simpleMessage(
          "Para una mejor experiencia, al usar nuestro Servicio, puedo pedirte que nos proporciones cierta información de identificación personal, incluyendo, entre otras, tu nombre y dirección de correo electrónico, que provienen de la cuenta de Google con la que inicias sesión. Esa información, junto con los servicios, clientes y ajustes que registras, se guarda en tu cuenta para estar disponible en cualquier dispositivo en el que inicies sesión.\nLa aplicación también usa servicios de terceros que pueden recopilar información utilizada para identificarte.\nEnlace a la política de privacidad de los proveedores de servicios de terceros utilizados por la aplicación:\n",
        ),
        "privacyPoliceInformation1": MessageLookupByLibrary.simpleMessage(
          "Servicios de Google Play",
        ),
        "privacyPoliceInformation2":
            MessageLookupByLibrary.simpleMessage("AdMob"),
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
          "Con tu permiso explícito, y solo con él, la aplicación puede grabar una sesión como una secuencia de capturas de pantalla, para que yo vea dónde se atasca la gente.\nTodo texto y toda imagen se enmascaran en tu dispositivo antes de cualquier envío. Lo que se almacena muestra la disposición, los toques y el desplazamiento, no lo que está escrito en la pantalla.\nLa grabación nunca viene activada por defecto. Se te pregunta una vez y puedes retirar el permiso cuando quieras en Menú > Privacidad, lo que la detiene de inmediato. No se graba toda sesión: se graba una muestra, más las sesiones en las que la aplicación detecta que algo salió mal.",
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
        "privacyReadFullVersion": MessageLookupByLibrary.simpleMessage(
          "Leer la versión completa",
        ),
        "privacySessionRecording": MessageLookupByLibrary.simpleMessage(
          "Grabación de sesión",
        ),
        "privacySessionRecordingDescription":
            MessageLookupByLibrary.simpleMessage(
          "Graba una repetición enmascarada de algunas sesiones. Todo el texto y las imágenes quedan ocultos.",
        ),
        "privacySummaryControl": MessageLookupByLibrary.simpleMessage(
          "Los datos de uso y la grabación de sesión se pueden desactivar en cualquier momento en Menú › Privacidad.",
        ),
        "privacySummaryControlTitle": MessageLookupByLibrary.simpleMessage(
          "Lo que controlas",
        ),
        "privacySummaryDelete": MessageLookupByLibrary.simpleMessage(
          "Toca aquí para escribirnos y eliminamos tus servicios, clientes y configuración.",
        ),
        "privacySummaryDeleteTitle": MessageLookupByLibrary.simpleMessage(
          "Eliminar tu cuenta",
        ),
        "privacySummaryNever": MessageLookupByLibrary.simpleMessage(
          "No vendemos tus datos. Los datos de uso nunca llevan tus importes, los nombres de tus clientes ni lo que escribes.",
        ),
        "privacySummaryNeverTitle": MessageLookupByLibrary.simpleMessage(
          "Lo que no hacemos",
        ),
        "privacySummaryStored": MessageLookupByLibrary.simpleMessage(
          "Tu correo electrónico, los servicios y clientes que registras y la configuración de la app.",
        ),
        "privacySummaryStoredTitle": MessageLookupByLibrary.simpleMessage(
          "Lo que guardamos",
        ),
        "privacyUpdatedOn": m54,
        "privacyUsageData": MessageLookupByLibrary.simpleMessage(
          "Ayudar a mejorar Kazi",
        ),
        "privacyUsageDataDescription": MessageLookupByLibrary.simpleMessage(
          "Envía eventos de uso anónimos para que descubramos qué no funciona. Nunca tus importes ni tus clientes.",
        ),
        "quantity": MessageLookupByLibrary.simpleMessage("Cantidad"),
        "quantityHint": MessageLookupByLibrary.simpleMessage(
          "Cuántas veces se prestó el servicio",
        ),
        "rateApp": MessageLookupByLibrary.simpleMessage("Calificar la app"),
        "ratesUnavailable": MessageLookupByLibrary.simpleMessage(
          "Tipos de cambio no disponibles",
        ),
        "received": MessageLookupByLibrary.simpleMessage("Recibido"),
        "receivedOn": m55,
        "receivedPlural": MessageLookupByLibrary.simpleMessage("Recibidos"),
        "registerService": MessageLookupByLibrary.simpleMessage(
          "Registrar servicio",
        ),
        "removeFilters":
            MessageLookupByLibrary.simpleMessage("Eliminar filtros"),
        "reopenService":
            MessageLookupByLibrary.simpleMessage("Reabrir servicio"),
        "replayConsentAccept": MessageLookupByLibrary.simpleMessage(
          "Permitir grabación",
        ),
        "replayConsentBody": MessageLookupByLibrary.simpleMessage(
          "Grabamos los toques y las pantallas para descubrir dónde Kazi te estorba. Los montos, nombres de clientes y cualquier texto escrito quedan ocultos en la grabación.\n\nPuedes desactivarlo cuando quieras, en Menú > Grabación de sesión.",
        ),
        "replayConsentDecline":
            MessageLookupByLibrary.simpleMessage("Ahora no"),
        "replayConsentLearnMore": MessageLookupByLibrary.simpleMessage(
          "Cómo se usa esto",
        ),
        "replayConsentTitle": MessageLookupByLibrary.simpleMessage(
          "¿Podemos grabar cómo usas la app?",
        ),
        "reportProblem": MessageLookupByLibrary.simpleMessage(
          "Reportar un problema",
        ),
        "reportProblemBody": m56,
        "reportProblemSubject": MessageLookupByLibrary.simpleMessage(
          "Reporte de problema",
        ),
        "requiredProperty": m57,
        "restore": MessageLookupByLibrary.simpleMessage("Restaurar"),
        "role": MessageLookupByLibrary.simpleMessage("Función"),
        "save": MessageLookupByLibrary.simpleMessage("Guardar"),
        "saving": MessageLookupByLibrary.simpleMessage("Guardando…"),
        "search": MessageLookupByLibrary.simpleMessage("Buscar"),
        "searchByName":
            MessageLookupByLibrary.simpleMessage("Buscar por nombre"),
        "searchClientsHint": MessageLookupByLibrary.simpleMessage(
          "Buscar por nombre",
        ),
        "searchIgnoresPeriod": MessageLookupByLibrary.simpleMessage(
          "La búsqueda ignora el período: busca en todo lo que registraste.",
        ),
        "searchServiceTypeHint": MessageLookupByLibrary.simpleMessage(
          "Buscar un tipo",
        ),
        "searchServicesFound": m58,
        "searchServicesHint": MessageLookupByLibrary.simpleMessage(
          "Tipo, cliente u observación",
        ),
        "seeInList": MessageLookupByLibrary.simpleMessage("Ver todo"),
        "seeInSummary":
            MessageLookupByLibrary.simpleMessage("Ver en el resumen"),
        "seeNServices": m59,
        "seeTheServices": m60,
        "selectCurrency": MessageLookupByLibrary.simpleMessage(
          "Selecciona una moneda",
        ),
        "service": MessageLookupByLibrary.simpleMessage("Servicio"),
        "serviceCancelled": MessageLookupByLibrary.simpleMessage(
          "Servicio cancelado",
        ),
        "serviceCatalog": MessageLookupByLibrary.simpleMessage(
          "Catálogo de servicios",
        ),
        "serviceCurrencyHint": MessageLookupByLibrary.simpleMessage(
          "Moneda en que se cobró el servicio",
        ),
        "serviceReopened": MessageLookupByLibrary.simpleMessage(
          "Servicio reabierto",
        ),
        "serviceStatusHint": MessageLookupByLibrary.simpleMessage(
          "Un servicio cancelado se queda en tu historial y sale de tus totales.",
        ),
        "serviceType": MessageLookupByLibrary.simpleMessage("Tipo de servicio"),
        "services": MessageLookupByLibrary.simpleMessage("Servicios"),
        "servicesCount": m61,
        "settings": MessageLookupByLibrary.simpleMessage("Ajustes"),
        "setupCatalogAddAnother": MessageLookupByLibrary.simpleMessage(
          "Agregar otro servicio",
        ),
        "setupCatalogBlankPrice": MessageLookupByLibrary.simpleMessage(
          "¿No sabes el precio? Déjalo en blanco: Kazi lo pregunta al registrar.",
        ),
        "setupCatalogContinueWith": m62,
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
        "setupCycleMonthlyDetail": m63,
        "setupCycleSubtitle": MessageLookupByLibrary.simpleMessage(
          "Kazi suma tus ganancias dentro de ese período.",
        ),
        "setupCycleTitle":
            MessageLookupByLibrary.simpleMessage("¿Cuándo cobras?"),
        "setupEmployed": MessageLookupByLibrary.simpleMessage(
          "Trabajo para un salón o empresa",
        ),
        "setupEmployedDetail": MessageLookupByLibrary.simpleMessage(
          "recibo comisión",
        ),
        "setupEssentialsCurrencyNote": MessageLookupByLibrary.simpleMessage(
          "Los servicios que ya registraste se guardan en esta moneda.",
        ),
        "setupEssentialsProfessionSubtitle":
            MessageLookupByLibrary.simpleMessage(
          "Tus servicios siguen tal como están. Tu profesión aparece en tu perfil.",
        ),
        "setupEssentialsProfessionTitle": MessageLookupByLibrary.simpleMessage(
          "Kazi tiene novedades. Primero: ¿a qué te dedicas?",
        ),
        "setupEssentialsProfessionTypedSubtitle":
            MessageLookupByLibrary.simpleMessage("Escríbelo a tu manera."),
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
        "setupProfessionField":
            MessageLookupByLibrary.simpleMessage("Profesión"),
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
        "setupResultBreakdown": m64,
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
        "showAllTypes": m65,
        "signOut": MessageLookupByLibrary.simpleMessage(
          "Cerrar sesión de la cuenta",
        ),
        "signOutConfirm": MessageLookupByLibrary.simpleMessage("Cerrar sesión"),
        "signOutConfirmation": MessageLookupByLibrary.simpleMessage(
          "Tus servicios siguen guardados. Para verlos de nuevo, solo inicia sesión con la misma cuenta.",
        ),
        "signOutTitle": MessageLookupByLibrary.simpleMessage("¿Cerrar sesión?"),
        "situation": MessageLookupByLibrary.simpleMessage("Situación"),
        "splashSignature":
            MessageLookupByLibrary.simpleMessage("kazi · trabajo"),
        "statPending": MessageLookupByLibrary.simpleMessage("Pendiente"),
        "statReceived": MessageLookupByLibrary.simpleMessage("Recibido"),
        "statusCancelled": MessageLookupByLibrary.simpleMessage("Cancelado"),
        "statusPending": MessageLookupByLibrary.simpleMessage("Pendiente"),
        "summary": MessageLookupByLibrary.simpleMessage("Resumen"),
        "telegram": MessageLookupByLibrary.simpleMessage("Telegram"),
        "theme": MessageLookupByLibrary.simpleMessage("Tema"),
        "themeChangeNote": MessageLookupByLibrary.simpleMessage(
          "El cambio es inmediato y vale para toda la app. La hoja sigue abierta para que compares.",
        ),
        "themeDark": MessageLookupByLibrary.simpleMessage("Oscuro"),
        "themeLight": MessageLookupByLibrary.simpleMessage("Claro"),
        "themeSystem": MessageLookupByLibrary.simpleMessage("Sistema"),
        "themeSystemDetail": MessageLookupByLibrary.simpleMessage(
          "sigue el dispositivo",
        ),
        "today": MessageLookupByLibrary.simpleMessage("Hoy"),
        "todaySection": m66,
        "topClients": MessageLookupByLibrary.simpleMessage(
          "Clientes que más rindieron",
        ),
        "tryAgain": MessageLookupByLibrary.simpleMessage("Intentar de nuevo"),
        "understood": MessageLookupByLibrary.simpleMessage("Entendido"),
        "undo": MessageLookupByLibrary.simpleMessage("Deshacer"),
        "unmarkAsReceived": MessageLookupByLibrary.simpleMessage(
          "Marcar como no recibido",
        ),
        "updateLater": MessageLookupByLibrary.simpleMessage("Más tarde"),
        "updateNow": MessageLookupByLibrary.simpleMessage("Actualizar"),
        "useExistingClient": m67,
        "usedIn": MessageLookupByLibrary.simpleMessage("Usado en"),
        "usedInServices": m68,
        "usesCount": m69,
        "validatorConfirmPassword": MessageLookupByLibrary.simpleMessage(
          "Las contraseñas no coinciden",
        ),
        "validatorEmail": MessageLookupByLibrary.simpleMessage(
          "Correo electrónico inválido",
        ),
        "validatorPassword": MessageLookupByLibrary.simpleMessage(
          "Tu contraseña debe tener al menos 8 caracteres y como máximo 16",
        ),
        "viewArchived": m70,
        "week": MessageLookupByLibrary.simpleMessage("7 días"),
        "whatWasDone": MessageLookupByLibrary.simpleMessage("Qué se hizo"),
        "whatsNewSubtitle": MessageLookupByLibrary.simpleMessage(
          "Tres cosas, escritas por nosotros, no descubiertas en medio de una atención.",
        ),
        "whatsNewTitle": MessageLookupByLibrary.simpleMessage("Qué cambió"),
        "whatsNewVersion": m71,
        "whatsapp": MessageLookupByLibrary.simpleMessage("WhatsApp"),
        "whoWasServed":
            MessageLookupByLibrary.simpleMessage("A quién atendiste"),
        "withoutCatalogItem": MessageLookupByLibrary.simpleMessage(
          "Fuera del catálogo",
        ),
        "withoutCommission":
            MessageLookupByLibrary.simpleMessage("sin comisión"),
        "yesterday": MessageLookupByLibrary.simpleMessage("Ayer"),
        "youKeep": MessageLookupByLibrary.simpleMessage("Te queda"),
        "yourEarnings": MessageLookupByLibrary.simpleMessage("Tu ganancia"),
        "yoursFromThis": m72,
      };
}
