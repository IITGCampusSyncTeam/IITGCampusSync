import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarFilterSlider extends StatefulWidget {
  const CalendarFilterSlider({super.key});

  /// Storage for last applied filters (runtime only, cleared on app restart)
  static Map<String, dynamic>? lastApplied;

  /// Helper to show the modal
  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const CalendarFilterSlider(),
    );
  }

  @override
  State<CalendarFilterSlider> createState() => _CalendarFilterSliderState();
}

class _CalendarFilterSliderState extends State<CalendarFilterSlider> {
  // --- Colors ---
  final Color _bg = const Color(0xFFF4F4F5);
  final Color _muted = const Color(0xFF27272A);
  final Color _border = const Color(0xFFE6E6EA);
  final Color _inputBg = const Color(0xffE4E4E7);
  final Color _black = Colors.black;
  final Color _accent = const Color(0xFFFF8B2D);

  // --- State Variables ---
  String? _quickDateSelected;
  DateTime? _from;
  DateTime? _to;

  String? _selectedVenue;
  String? _locationSelected;
  final List<String> _locations = ['New Sac', 'Main Lawn', 'Auditorium'];

  final List<String> _quickDates = [
    'This Week',
    'This Month',
    'Next 30 Days',
    'Past 30 Days',
    'This Semester'
  ];

  // final List<String> _audienceQuick = [ 'Freshers', 'B. Freshers', 'All Design', 'B.Tech', 'B.Des', '3rd B.Tech' ];
  // final Set<String> _audienceQuickSelected = {};

  // String? _deptSelected;
  // final List<String> _departments = [ 'All Departments', 'CSE', 'EE', 'ME', 'Design' ];

  final TextEditingController _tagController = TextEditingController();

  // bool _yearBachelors = false;
  // bool _yearMasters = false;
  // bool _yearResearch = false;
  // String _bachelorsYear = 'All Years';
  // String _mastersYear = 'All Years';
  // final List<String> _bachelorYearsList = ['All Years', '1st Year', '2nd Year', '3rd Year', '4th Year'];
  // final List<String> _masterYearsList = ['All Years', '1st Year', '2nd Year'];
  
  // final List<String> _organizerQuick = [ 'Sports', 'Technical', 'Cultural', 'Welfare', 'Fests', 'Hostel' ];
  final Set<String> _organizerQuickSelected = {};
  
  bool _underGymkhana = false;
  String _gymkhanaBoard = 'All Boards';
  final List<String> _boardsList = ['All Boards', 'Board A', 'Board B', 'Board C'];

  // bool _deptLevel = false;
  // String _deptBody = 'All';
  // final List<String> _deptBodiesList = ['All', 'Dept A', 'Dept B', 'Dept C'];

  // bool _audienceExpanded = true;
  bool _organizerExpanded = true;
  
  // bool _bachelorsExpanded = false;
  // bool _mastersExpanded = false;
  bool _gymkhanaExpanded = false;
  // bool _deptLevelExpanded = false;

  @override
  void initState() {
    super.initState();
    if (CalendarFilterSlider.lastApplied != null) {
      final f = CalendarFilterSlider.lastApplied!;
      _quickDateSelected = f['quickDate'];
      _from = f['from'];
      _to = f['to'];
      _selectedVenue = f['venue'];
      _locationSelected = f['location'];
      // _audienceQuickSelected.addAll(List<String>.from(f['audienceQuick'] ?? []));
      // _deptSelected = f['department'];
      // final years = f['years'] as Map<String, dynamic>? ?? {};
      // _yearBachelors = years['bachelorsChecked'] ?? false;
      // _bachelorsYear = years['bachelorsYear'] ?? 'All Years';
      // _yearMasters = years['mastersChecked'] ?? false;
      // _mastersYear = years['mastersYear'] ?? 'All Years';
      // _yearResearch = years['research'] ?? false;      
      _organizerQuickSelected.addAll(List<String>.from(f['organizerQuick'] ?? []));
      final organizers = f['organizers'] as Map<String, dynamic>? ?? {};
      _underGymkhana = organizers['gymkhanaChecked'] ?? false;
      _gymkhanaBoard = organizers['gymkhanaBoard'] ?? 'All Boards';
      // _deptLevel = organizers['deptLevelChecked'] ?? false;
      // _deptBody = organizers['deptBody'] ?? 'All';
       
      // _bachelorsExpanded = _yearBachelors;
      // _mastersExpanded = _yearMasters;
      _gymkhanaExpanded = _underGymkhana;
      // _deptLevelExpanded = _deptLevel;
    } else {
      _locationSelected = null;
      // _deptSelected = null;
    }
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  void _resetAll() {
    setState(() {
      _quickDateSelected = null;
      _from = null;
      _to = null;
      _selectedVenue = null;
      _locationSelected = null;
      // _audienceQuickSelected.clear();
      // _deptSelected = null;
      // _tagController.clear();
      // _yearBachelors = false;
      // _yearMasters = false;
      // _yearResearch = false;
      // _bachelorsYear = 'All Years';
      // _mastersYear = 'All Years';
      _organizerQuickSelected.clear();
      _underGymkhana = false;
      // _deptLevel = false;
      _gymkhanaBoard = 'All Boards';
      // _deptBody = 'All';
      // _bachelorsExpanded = false;
      // _mastersExpanded = false;
      _gymkhanaExpanded = false;
      // _deptLevelExpanded = false;
      CalendarFilterSlider.lastApplied = null;
    });
  }

  void _applyFilters() {
      final applied = <String, dynamic>{
        // 'quickDate': _quickDateSelected,
        'from': _from,
        'to': _to,
        'venue': _selectedVenue,
        'location': _locationSelected,
        // 'audienceQuick': _audienceQuickSelected.toList(),
        // 'department': _deptSelected,
        // 'years': {
        //   'bachelorsChecked': _yearBachelors,
        //   'bachelorsYear': _bachelorsYear,
        //   'mastersChecked': _yearMasters,
        //   'mastersYear': _mastersYear,
        //   'research': _yearResearch,
        // },
        // 'organizerQuick': _organizerQuickSelected.toList(),
        'organizers': {
          'gymkhanaChecked': _underGymkhana,
          'gymkhanaBoard': _gymkhanaBoard,
        },
        // --- Commented out Apply logic for reference ---
        // 'audienceQuick': _audienceQuickSelected.toList(),
        // 'department': _deptSelected,
        // 'years': {
        //   'bachelorsChecked': _yearBachelors,
        //   'bachelorsYear': _bachelorsYear,
        //   'mastersChecked': _yearMasters,
        //   'mastersYear': _mastersYear,
        //   'research': _yearResearch,
        // },
        // 'organizers': {
        //   'gymkhanaChecked': _underGymkhana,
        //   'gymkhanaBoard': _gymkhanaBoard,
        //   'deptLevelChecked': _deptLevel,
        //   'deptBody': _deptBody,
        // }
      };
      CalendarFilterSlider.lastApplied = applied;
      Navigator.of(context).pop(applied);
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    return DateFormat('d MMM yyyy').format(d);
  }

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _from : _to) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _from = picked;
        } else {
          _to = picked;
        }
        _quickDateSelected = null;
      });
    }
  }

  Widget _grabBar() => Center(
    child: Container(
      width: 40,
      height: 5,
      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
    ),
  );

  Widget _chip(String label, {required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _black : _border),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : _black)),
      ),
    );
  }
  
  Widget _dateBox(String text, VoidCallback onTap, String hint) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: _inputBg, borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Expanded(child: Text(
                  text.isEmpty ? hint : text, 
                  style: TextStyle(fontSize: 14, color: text.isEmpty ? _muted : _black)
                )
              ),
              const Icon(Icons.calendar_today_outlined, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdown(String hint, String? value, List<String> items, ValueChanged<String?>? onChanged) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: _inputBg, borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint, style: TextStyle(color: const Color(0xff71717B), fontWeight: FontWeight.w400, fontSize: 16),),
          value: value,
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(
            value: e, 
            child: Text(e, style: const TextStyle(fontSize: 14)),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
  
  Widget _smallRadio(String val, String label) {
    return RadioListTile<String>(
      title: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Color(0xff27272A))),
      value: val,
      groupValue: _selectedVenue,
      onChanged: (v) => setState(() {
        if (_selectedVenue == v) {
          _selectedVenue = null;
        } else {
          _selectedVenue = v;
        }
      }),
      contentPadding: EdgeInsets.zero,
      activeColor: Colors.black,
      toggleable: true,
    );
  }
  
  Widget _sectionTitle(String text) => Text(
    text, 
    style: const TextStyle(
      fontSize: 16, 
      fontWeight: FontWeight.w400, color: Color(0xff27272A)
    )
  );

  Widget _subTitle(String text) => Text(
    text, 
    style: const TextStyle(
      fontSize: 14, 
      color: Color(0xff71717B), 
      fontWeight: FontWeight.w500
    )
  );

  Widget _collapsibleContainer({
    required String title,
    required bool isExpanded,
    required VoidCallback onExpandToggle,
    required bool isChecked,
    required ValueChanged<bool?> onCheckboxChanged,
    required String dropdownLabel,
    required String dropdownValue,
    required List<String> dropdownItems,
    required ValueChanged<String?> onDropdownChanged,
  }) {
    if (isExpanded) {
      // Expanded view
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onExpandToggle,
              child: Row(
                children: [
                  Checkbox(
                    value: isChecked, 
                    onChanged: onCheckboxChanged, 
                    activeColor: Colors.black,
                  ),
                  Expanded(child: Text(title)),
                  Icon(Icons.keyboard_arrow_up, color: _muted),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _subTitle(dropdownLabel),
            const SizedBox(height: 4),
            _dropdown(dropdownValue, dropdownValue, dropdownItems, isChecked ? onDropdownChanged : null),
          ],
        ),
      );
    } else {
      // Collapsed view
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onExpandToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Row(
                children: [
                  // Checkbox(value: isChecked, onChanged: onCheckboxChanged, activeColor: Colors.black),
                  Checkbox(
                    value: isChecked, 
                    onChanged: onCheckboxChanged, 
                    activeColor: Colors.black,
                  ),
                  Expanded(child: Text(title)),
                  const SizedBox(width: 8),
                  Icon(Icons.keyboard_arrow_down, color: _muted),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(color: _bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(22))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14.0, bottom: 12.0),
            child: _grabBar(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: const [
                Text(
                  'Filters', 
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.w500,
                    color: Color(0xff27272A),
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Range
                    _sectionTitle('Date Range'),
                    const SizedBox(height: 8),
                    _subTitle('Quick Selection'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0, runSpacing: 8.0,
                      children: _quickDates.map((d) {
                        final sel = _quickDateSelected == d;
                        return _chip(d, selected: sel, onTap: () {
                          setState(() {
                            if (sel) {
                              _quickDateSelected = null;
                              _from = null;
                              _to = null;
                            } else {
                              _quickDateSelected = d;
                              final now = DateTime.now();
                              switch (d) {
                                case 'This Week':
                                  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                                  _from = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
                                  _to = _from!.add(const Duration(days: 6));
                                  break;
                                case 'This Month':
                                  _from = DateTime(now.year, now.month, 1);
                                  _to = DateTime(now.year, now.month + 1, 0);
                                  break;
                                case 'Next 30 Days':
                                  _from = now;
                                  _to = now.add(const Duration(days: 30));
                                  break;
                                case 'Past 30 Days':
                                  _from = now.subtract(const Duration(days: 30));
                                  _to = now;
                                  break;
                                // case 'This Semester':
                                //   if (now.month >= 1 && now.month <= 5) { // Jan - May
                                //     _from = DateTime(now.year, 1, 1);
                                //     _to = DateTime(now.year, 5, 31);
                                //   } else if (now.month >= 8 && now.month <= 12) { // Aug - Dec
                                //     _from = DateTime(now.year, 8, 1);
                                //     _to = DateTime(now.year, 12, 31);
                                //   }
                                //   break;
                              }
                            }
                          });
                        });
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: _subTitle('From')),
                        Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(8, 0, 0, 0), child: _subTitle('To'))),
                      ],
                    ),
                    Row(children: [
                      _dateBox(_formatDate(_from), () => _pickDate(context, true), '19 Jul 2025'),
                      const SizedBox(width: 12),
                      _dateBox(_formatDate(_to), () => _pickDate(context, false), '19 Jul 2025'),
                    ]),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(onTap: () {}, child: Text('+ Add Time', style: TextStyle(color: _accent, fontWeight: FontWeight.w600))),
                    ),
                    const SizedBox(height: 18),
                    Divider(color: _border, thickness: 1),
                    const SizedBox(height: 12),

                    // Venue
                    _sectionTitle('Venue'),
                    const SizedBox(height: 8),
                    _smallRadio('On-Campus', 'On-Campus'),
                    _smallRadio('Off-Campus', 'Off-Campus (Physical)'),
                    _smallRadio('Online', 'Online'),
                    const SizedBox(height: 12),
                    _subTitle('Location'),
                    const SizedBox(height: 8),
                    _dropdown('New Sac', _locationSelected, _locations, (val) => setState(() => _locationSelected = val)),
                    const SizedBox(height: 18),
                    Divider(color: _border, thickness: 1),
                    const SizedBox(height: 12),
                    
                    // Audience
                    // InkWell(
                    //   onTap: () => setState(() => _audienceExpanded = !_audienceExpanded),
                    //   child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    //     _sectionTitle('Audience'),
                    //     Icon(_audienceExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                    //   ]),
                    // ),
                    // if (_audienceExpanded) ...[
                    //   const SizedBox(height: 8),
                    //   _subTitle('Quick Selection'),
                    //   const SizedBox(height: 8),
                    //   Wrap(
                    //     spacing: 8.0, runSpacing: 8.0,
                    //     children: _audienceQuick.map((c) {
                    //       final sel = _audienceQuickSelected.contains(c);
                    //       return _chip(
                    //         c, selected: sel, 
                    //         onTap: () => setState(() => 
                    //           sel ? _audienceQuickSelected.remove(c) : _audienceQuickSelected.add(c)
                    //         ));
                    //     }).toList(),
                    //   ),
                    //   const SizedBox(height: 12),
                    //   _subTitle('Department'),
                    //   const SizedBox(height: 8),
                    //   _dropdown('All Departments', _deptSelected, _departments, (val) => setState(() => _deptSelected = val)),
                    //   const SizedBox(height: 12),
                    //   _subTitle('Tags / Interests'),
                    //   const SizedBox(height: 8),
                    //   TextField(
                    //     controller: _tagController,
                    //     decoration: InputDecoration(
                    //       hintText: 'Add', filled: true, fillColor: _inputBg,
                    //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    //       suffixIcon: IconButton(icon: const Icon(Icons.add), onPressed: () {}),
                    //     ),
                    //   ),
                    //   const SizedBox(height: 12),
                    //   _subTitle('Year wise'),
                    //   const SizedBox(height: 8),
                    //   _collapsibleContainer(
                    //       title: 'Bachelors', isExpanded: _bachelorsExpanded,
                    //       onExpandToggle: () => setState(() => _bachelorsExpanded = !_bachelorsExpanded),
                    //       isChecked: _yearBachelors,
                    //       onCheckboxChanged: (v) => setState(() {
                    //         _yearBachelors = v ?? false;
                    //         _bachelorsExpanded = _yearBachelors;
                    //       }),
                    //       dropdownLabel: 'Year',
                    //       dropdownValue: _bachelorsYear, dropdownItems: _bachelorYearsList,
                    //       onDropdownChanged: (v) => setState(() => _bachelorsYear = v ?? 'All Years'),
                    //   ),
                    //   const SizedBox(height: 8),
                    //    _collapsibleContainer(
                    //       title: 'Masters', isExpanded: _mastersExpanded,
                    //       onExpandToggle: () => setState(() => _mastersExpanded = !_mastersExpanded),
                    //       isChecked: _yearMasters,
                    //       onCheckboxChanged: (v) => setState(() {
                    //         _yearMasters = v ?? false;
                    //         _mastersExpanded = _yearMasters;
                    //       }),
                    //       dropdownLabel: 'Year',
                    //       dropdownValue: _mastersYear, dropdownItems: _masterYearsList,
                    //       onDropdownChanged: (v) => setState(() => _mastersYear = v ?? 'All Years'),
                    //   ),
                    //   const SizedBox(height: 8),
                    //    Container(
                    //      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
                    //      child: Row(
                    //        children: [
                    //          Checkbox(
                    //            value: _yearResearch, 
                    //            onChanged: (v) => setState(() => _yearResearch = v ?? false), 
                    //            activeColor: Colors.blue
                    //          ),
                    //          const Text('Research Students')
                    //        ]
                    //      ),
                    //    ),
                    // ],
                    // const SizedBox(height: 18),
                    // Divider(color: _border, thickness: 1),
                    // const SizedBox(height: 12),

                    // Organizer
                    InkWell(
                      onTap: () => setState(() => _organizerExpanded = !_organizerExpanded),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        _sectionTitle('Organizer'),
                        Icon(_organizerExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                      ]),
                    ),
                    if (_organizerExpanded) ...[
                      // const SizedBox(height: 8),
                      // _subTitle('Quick Selection'),
                      // const SizedBox(height: 8),
                      // Wrap(
                      //    spacing: 8.0, runSpacing: 8.0,
                      //    children: _organizerQuick.map((c) {
                      //     final sel = _organizerQuickSelected.contains(c);
                      //     return _chip(c, selected: sel, onTap: () => setState(() => sel ? _organizerQuickSelected.remove(c) : _organizerQuickSelected.add(c)));
                      //    }).toList(),
                      // ),
                      const SizedBox(height: 12),
                      _subTitle('Organizers'),
                      const SizedBox(height: 8),
                      _collapsibleContainer(
                        title: 'Under Gymkhana', isExpanded: _gymkhanaExpanded,
                        onExpandToggle: () => setState(() => _gymkhanaExpanded = !_gymkhanaExpanded),
                        isChecked: _underGymkhana,
                        onCheckboxChanged: (v) => setState(() {
                          _underGymkhana = v ?? false;
                          _gymkhanaExpanded = _underGymkhana;
                        }),
                        dropdownLabel: 'Boards', dropdownValue: _gymkhanaBoard, dropdownItems: _boardsList,
                        onDropdownChanged: (v) => setState(() => _gymkhanaBoard = v ?? 'All Boards'),
                      ),
                      //  const SizedBox(height: 8),
                      //  _collapsibleContainer(
                      //   title: 'Department Level', isExpanded: _deptLevelExpanded,
                      //   onExpandToggle: () => setState(() => _deptLevelExpanded = !_deptLevelExpanded),
                      //   isChecked: _deptLevel,
                      //   onCheckboxChanged: (v) => setState(() {
                      //     _deptLevel = v ?? false;
                      //     _deptLevelExpanded = _deptLevel;
                      //   }),
                      //   dropdownLabel: 'Dept. Level Bodies', dropdownValue: _deptBody, dropdownItems: _deptBodiesList,
                      //   onDropdownChanged: (v) => setState(() => _deptBody = v ?? 'All'),
                      // ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 18.0, 16.0, 18.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetAll,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xffE4E4E7),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    child: Text('Reset', style: TextStyle(color: _black)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}