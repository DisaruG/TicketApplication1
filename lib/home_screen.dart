import 'package:flutter/material.dart';
import 'logout_screen.dart';
import 'task_screen_delegate.dart';
import 'tasks_list_screen.dart';
import 'contacts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const TasksListScreen(),
    const ContactsScreen(),
    const LogoutScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0 ? buildAppBar() : null, // Show AppBar only on home screen
      body: buildContentArea(),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: const Text(
        'Dashboard',
        style: TextStyle(color: Color(0xFF333333)), // Charcoal Gray
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Color(0xFF003366)), // Deep Navy Blue
          onPressed: () {
            showSearch(
              context: context,
              delegate: TicketSearchDelegate(),
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(10.0),
        child: Container(
          color: const Color(0xFFF4F4F4), // Soft Gray
          height: 1.0,
        ),
      ),
    );
  }

  Widget buildContentArea() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _widgetOptions.elementAt(_selectedIndex),
    );
  }

  Widget buildBottomNavigationBar() {
    return CustomBottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> labels = ['Tasks', 'Contacts', 'Profile'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF003366).withOpacity(0.2), // Deep Navy Blue with opacity
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(3, (index) {
            final isSelected = currentIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(index),
                child: Container(
                  height: 50.0,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: isSelected ? 50.0 : 0.0,
                            height: isSelected ? 25.0 : 0.0,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF003366).withOpacity(0.1) // Light Deep Navy Blue
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          Icon(
                            index == 0
                                ? Icons.assignment
                                : index == 1
                                ? Icons.contacts
                                : Icons.person,
                            color: isSelected ? const Color(0xFF003366) : const Color(0xFF333333), // Deep Navy Blue / Charcoal Gray
                            size: 24.0, // Adjust icon size
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        labels[index],
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF003366) : const Color(0xFF333333), // Deep Navy Blue / Charcoal Gray
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
