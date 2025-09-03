import 'package:calc_wood/src/presentation/pages/invoices/invoice_date_page.dart';
import 'package:calc_wood/src/presentation/pages/invoices/invoice_page.dart';
import 'package:flutter/material.dart';
import '../cashbox/cashbox_page.dart';
import '../clients/client_form_page.dart';
import '../clients/clients_page.dart';
import '../expense/expenses_page.dart';
import '../invoices/invoice_form_page.dart';
import '../invoices/invoice_preview_page.dart';
import '../products/product_list_page.dart';
import '../purchases/purchases_dates_page.dart';
import '../reports/daily_journal_page.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      {'title': 'invouce date page', 'icon': Icons.account_balance_wallet, 'page': const InvoiceDatesPage()},
      {'title': 'Cashbox', 'icon': Icons.account_balance_wallet, 'page': const CashboxPage()},
      {'title': 'Client Form Page', 'icon': Icons.person_add, 'page': const ClientFormDialog()},
      {'title': 'Clients Page', 'icon': Icons.group, 'page': const ClientsPage()},
      {'title': 'Expenses Page', 'icon': Icons.money_off, 'page': const ExpensesPage()},
      {'title': 'Invoice Form Page', 'icon': Icons.receipt_long, 'page': const InvoiceFormPage(data: {},)},
      //{'title': 'Invoice Preview Page', 'icon': Icons.preview, 'page': const InvoicePreviewPage(invoice: null,)},
      {'title': 'Product List', 'icon': Icons.view_list, 'page': const ProductListPage()},
      {'title': 'Purchases Dates Page', 'icon': Icons.date_range, 'page': const PurchasesDatesPage()},
      {'title': 'Daily Journal Page', 'icon': Icons.book, 'page': const DailyJournalPage()},
      //{'title': 'Invoice', 'icon': Icons.book, 'page': const InvoicePage(date: null, invoices: [],)},

    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("📋 القائمة الرئيسية"),
        centerTitle: true,
        elevation: 2,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: pages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = pages[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Icon(item['icon'] as IconData, color: Colors.blue),
              ),
              title: Text(
                item['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item['page'] as Widget),
                );
              },
            ),
          );
        },
      ),
    );
  }
}