import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  if (await login()) {
    await showMenu();
  }
  print("Bye -----");
}

Future<bool> login() async {
  print("===== Login =====");
  stdout.write("Username: ");
  String? username = stdin.readLineSync()?.trim();
  stdout.write("Password: ");
  String? password = stdin.readLineSync()?.trim();

  var url = Uri.parse('http://localhost:9000/login');
  var response = await http.post(url, body: {'username': username, 'password': password});

  if (response.statusCode == 200) {
    print("Login OK");
    return true;
  } else {
    print("Invalid credentials");
    return false;
  }
}

Future<void> showMenu() async {
  while (true) {
    print("========= Expense Tracking App =========");
    print("Welcome Tom");
    print("1. All expenses");
    print("2. Today's expense");
    print("3. Search expense");
    print("4. Add new expense");
    print("5. Delete an expense");
    print("6. Exit");
    stdout.write("Choose... ");

    String? choice = stdin.readLineSync()?.trim();

    switch (choice) {
      case "1":
        await showAllExpenses();
        break;
      case "2":
        await showTodayExpenses();
        break;
      case "3":
        await searchExpenses();
        break;
      case "4":
        await addNewExpense();
        break;
      case "5":
        await deleteExpense();
        break;
      case "6":
        return;
      default:
        print("Invalid choice. Please try again.");
    }
  }
}

Future<void> showAllExpenses() async {
  var url = Uri.parse('http://localhost:9000/expenses');
  var response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> expenses = jsonDecode(response.body);

    print("---------- All expenses ----------");
    int total = 0;
    for (var expense in expenses) {
      print("${expense['id']}. ${expense['item']} : ${expense['paid']}฿ - ${expense['date']}");
      total += int.parse(expense['paid'].toString());
    }
    print("Total expenses = $total");
  } else {
    print("Error retrieving expenses.");
  }
}

Future<void> showTodayExpenses() async {
  var url = Uri.parse('http://localhost:9000/expenses/today');
  var response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> expenses = jsonDecode(response.body);

    print("---------- Today's expenses ----------");
    if (expenses.isEmpty) {
      print("No item paid today.");
    } else {
      int total = 0;
      for (var expense in expenses) {
        print("${expense['id']}. ${expense['item']} : ${expense['paid']}฿ - ${expense['date']}");
        total += int.parse(expense['paid'].toString());
      }
      print("Total expenses = $total");
    }
  } else {
    print("Error retrieving today's expenses.");
  }
}

Future<void> searchExpenses() async {
  stdout.write("Enter item to search: ");
  String? searchItem = stdin.readLineSync()?.trim();

  if (searchItem == null || searchItem.isEmpty) {
    print("Invalid search term.");
    return;
  }

  var url = Uri.parse('http://localhost:9000/expenses/search');
  var response = await http.post(url, body: {'item': searchItem});

  if (response.statusCode == 200) {
    List<dynamic> expenses = jsonDecode(response.body);

    if (expenses.isEmpty) {
      print("No expenses found for $searchItem.");
    } else {
      int total = 0;
      for (var i = 0; i < expenses.length; i++) {
        var expense = expenses[i];
        print("${i + 1}. ${expense['item']} : ${expense['paid']}฿ - ${expense['date']}");
        total += int.parse(expense['paid'].toString());

      }
      print("Total expenses = $total");
    }
  } else {
    print("Error searching expenses.");
  }
}

Future<void> addNewExpense() async {
  print("===== Add new item =====");
  stdout.write("Item: ");
  String? item = stdin.readLineSync()?.trim();
  stdout.write("Paid: ");
  String? paid = stdin.readLineSync()?.trim();

  if (item == null || item.isEmpty || paid == null || paid.isEmpty) {
    print("Invalid input.");
    return;
  }

  var url = Uri.parse('http://localhost:9000/expenses');
  var response = await http.post(url, body: {'item': item, 'paid': paid});

  if (response.statusCode == 200) {
    print("Inserted!");
  } else {
    print("Error adding expense.");
  }
}

Future<void> deleteExpense() async {
  print("===== Delete an item =====");
  stdout.write("Item ID: ");
  String? id = stdin.readLineSync()?.trim();

  if (id == null || id.isEmpty) {
    print("Invalid ID.");
    return;
  }

  stdout.write("Are you sure? (y/n): ");
  String? confirmation = stdin.readLineSync()?.trim().toLowerCase();

  if (confirmation != 'y') {
    print("Deletion cancelled.");
    return;
  }

  var url = Uri.parse('http://localhost:9000/expenses/$id');
  var response = await http.delete(url);

  if (response.statusCode == 200) {
    print("Item deleted.");
  } else {
    print("Error deleting expense.");
  }
}