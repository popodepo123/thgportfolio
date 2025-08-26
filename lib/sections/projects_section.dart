import 'package:flutter/material.dart';
import 'package:thgportfolio/portfolio_data.dart';
import 'package:thgportfolio/theme.dart';

class ProjectsSection extends StatefulWidget {
  const ProjectsSection({super.key});

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection> {
  final Map<int, bool> _expandedStates = {};

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Featured Projects', style: textTheme.headlineMedium),
          const SizedBox(height: 16),
          ...portfolio.projects.asMap().entries.map((entry) {
            final index = entry.key;
            final project = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                    child: Text(project.title, style: textTheme.titleLarge),
                  ),
                  Padding(
                    // Padding for the description
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
                    child: Text(
                      project.description,
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  if (project.images != null && project.images!.isNotEmpty)
                    SizedBox(
                      height: 200, // Fixed height for the image carousel
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: project
                            .images!.length, // Changed imageUrls to images
                        itemBuilder: (context, imageIndex) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      final PageController
                                          galleryPageController =
                                          PageController(
                                        initialPage: imageIndex,
                                      );
                                      final ValueNotifier<int>
                                          currentPageNotifier =
                                          ValueNotifier<int>(
                                        imageIndex,
                                      );

                                      galleryPageController.addListener(() {
                                        currentPageNotifier.value =
                                            galleryPageController.page!.round();
                                      });

                                      return Dialog(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.9,
                                            maxHeight: MediaQuery.of(
                                                  context,
                                                ).size.height *
                                                0.9,
                                          ),
                                          child: Stack(
                                            children: [
                                              PageView.builder(
                                                controller:
                                                    galleryPageController,
                                                itemCount:
                                                    project.images!.length,
                                                itemBuilder:
                                                    (context, galleryIndex) {
                                                  return Image.network(
                                                    project
                                                        .images![galleryIndex]
                                                        .url,
                                                    fit: BoxFit.contain,
                                                    semanticLabel: project
                                                        .images![galleryIndex]
                                                        .title,
                                                  );
                                                },
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                left: 0,
                                                right: 0,
                                                child:
                                                    ValueListenableBuilder<int>(
                                                  valueListenable:
                                                      currentPageNotifier,
                                                  builder: (context,
                                                      currentPage, child) {
                                                    return Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                        8.0,
                                                      ),
                                                      color: Colors.black54,
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            project
                                                                .images![
                                                                    currentPage]
                                                                .title, // Display title
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleLarge
                                                                ?.copyWith(
                                                                  color: Colors
                                                                      .white,
                                                                ), // Style for title
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            project
                                                                .images![
                                                                    currentPage]
                                                                .description, // Display description
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium
                                                                ?.copyWith(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              Positioned(
                                                top: 8,
                                                left: 0,
                                                right: 0,
                                                child:
                                                    ValueListenableBuilder<int>(
                                                  valueListenable:
                                                      currentPageNotifier,
                                                  builder: (context,
                                                      currentPage, child) {
                                                    return Center(
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black54,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            8,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          '${currentPage + 1} of ${project.images!.length}',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall
                                                                  ?.copyWith(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              Positioned(
                                                top: 8,
                                                right:
                                                    8, // Adjusted position to avoid overlap
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  tooltip: 'Close',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  child: SizedBox(
                                    width:
                                        100, // Adjusted width for smartphone aspect ratio
                                    height:
                                        180, // Adjusted height for smartphone aspect ratio
                                    child: Image.network(
                                      project.images![imageIndex].url,
                                      fit: BoxFit.cover,
                                      semanticLabel:
                                          project.images![imageIndex].title,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ExpansionTile(
                      initiallyExpanded: _expandedStates[index] ?? false,
                      onExpansionChanged: (bool expanded) {
                        setState(() {
                          _expandedStates[index] = expanded;
                        });
                      },
                      title: Text('Features', style: textTheme.titleMedium),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            16.0,
                            0,
                            16.0,
                            16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              ...project.features.map(
                                (feature) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '\u2022 ',
                                        style: TextStyle(color: primaryColor),
                                      ),
                                      Expanded(
                                        child: Text(
                                          feature,
                                          style: textTheme.bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
