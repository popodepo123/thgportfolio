import 'package:flutter/material.dart';

enum PortfolioView { professional, dev }

final ValueNotifier<PortfolioView> portfolioViewNotifier =
    ValueNotifier<PortfolioView>(PortfolioView.professional);
