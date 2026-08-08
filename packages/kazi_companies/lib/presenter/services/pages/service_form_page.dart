// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:kazi_companies/core/routes/routes.dart';
// import 'package:kazi_companies/presenter/services/cubit/services_form_cubit.dart';
// import 'package:kazi_core/kazi_core.dart';

// class ServiceFormPage extends StatefulWidget {
//   const ServiceFormPage({super.key});

//   @override
//   State<ServiceFormPage> createState() => _ServiceFormPageState();
// }

// class _ServiceFormPageState extends State<ServiceFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   late final ServicesFormCubit _cubit;
//   late final TextEditingController _startTimeController;
//   late final TextEditingController _endTimeController;

//   @override
//   void initState() {
//     _cubit = context.read();
//     _startTimeController = TextEditingController();
//     _endTimeController = TextEditingController();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text(
//         'Add Service',
//         style: KaziTextStyles.titleMd,
//       ),
//       backgroundColor: context.colorsScheme.surface,
//       content: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: BlocBuilder<ServicesFormCubit, ServicesFormState>(
//             bloc: _cubit,
//             builder: (context, state) => Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 KaziDropdown(
//                   label: KaziLocalizations.current.serviceType,
//                   items: state.serviceTypes,
//                   hint: 'Select Service Type',
//                   onChanged: _cubit.onServiceTypeChanged,
//                   searchLabel: '',
//                   noResultsLabel: '',
//                 ),
//                 KaziSpacings.verticalMd,
//                 KaziDatePicker(
//                   initialDate: DateTime.now(),
//                   onChange: _cubit.onStartTimeChanged,
//                   label: 'Start Time',
//                   firstDate: DateTime(2024),
//                   lastDate: DateTime(2026),
//                   controller: _startTimeController,
//                 ),
//                 KaziSpacings.verticalMd,
//                 KaziDatePicker(
//                   initialDate: DateTime.now(),
//                   onChange: (date) {
//                     _cubit.onStartTimeChanged(date);
//                     _startTimeController.text = date.toString();
//                     _endTimeController.text = date.toString();
//                   },
//                   label: 'End Time',
//                   firstDate: DateTime(2024),
//                   lastDate: DateTime(2026),
//                   controller: _endTimeController,
//                 ),
//                 KaziSpacings.verticalMd,
//                 KaziDropdown(
//                   label: 'Client',
//                   items: state.customers,
//                   hint: 'Select Customer',
//                   onChanged: _cubit.onSelectCustomer,
//                   searchLabel: '',
//                   noResultsLabel: '',
//                 ),
//                 KaziSpacings.verticalMd,
//                 KaziDropdown(
//                   label: KaziLocalizations.current.employee,
//                   items: state.employees,
//                   hint: 'Select Employee',
//                   onChanged: _cubit.onSelectEmployee,
//                   searchLabel: '',
//                   noResultsLabel: '',
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: context.closeDialog,
//           style: TextButton.styleFrom(
//             foregroundColor: context.colorsScheme.onSurfaceVariant,
//           ),
//           child: Text(KaziLocalizations.current.cancel),
//         ),
//         TextButton(
//           onPressed: () {
//             if (_formKey.currentState!.validate()) {
//               context.closeDialog();
//             }
//           },
//           child: Text(KaziLocalizations.current.save),
//         ),
//       ],
//     );
//   }
// }
