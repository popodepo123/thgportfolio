import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:thgportfolio/contribution_service.dart";

void main() {
  group("ContributionService", () {
    test(
      "loads GitHub contributions directly without the retired proxy",
      () async {
        final client = MockClient((request) async {
          expect(request.url.host, "github-contributions-api.jogruber.de");
          expect(request.url.path, "/v4/popodepo123");
          expect(request.url.queryParameters["y"], "last");
          expect(request.url.toString(), isNot(contains("corsproxy.io")));
          return http.Response(
            jsonEncode({
              "contributions": [
                {"date": "2026-08-24", "count": 7, "level": 3},
              ],
            }),
            200,
          );
        });

        final contributions = await ContributionService.fetchGitHub(
          "popodepo123",
          client: client,
        );

        expect(contributions, {"2026-08-24": 7});
      },
    );

    test(
      "paginates and aggregates public GitLab contribution events",
      () async {
        final requestedPages = <int>{};
        final client = MockClient((request) async {
          expect(request.url.host, "gitlab.com");
          expect(request.url.path, "/api/v4/users/godoytristanh/events");
          expect(request.url.queryParameters["per_page"], "100");
          expect(request.url.queryParameters["after"], isNotEmpty);
          expect(request.url.toString(), isNot(contains("corsproxy.io")));

          final page = int.parse(request.url.queryParameters["page"]!);
          requestedPages.add(page);
          if (page == 1) {
            return http.Response(
              jsonEncode([
                {
                  "project_id": 7,
                  "action_name": "pushed new",
                  "target_type": "Project",
                  "created_at": "2026-08-24T09:00:00.000Z",
                  "push_data": {"commit_count": 12},
                },
                {
                  "project_id": 7,
                  "action_name": "created",
                  "target_type": "Project",
                  "created_at": "2026-08-24T08:59:00.000Z",
                },
                {
                  "project_id": 7,
                  "action_name": "created",
                  "target_type": "Issue",
                  "created_at": "2026-08-24T10:00:00.000Z",
                },
              ]),
              200,
              headers: {"x-total-pages": "2"},
            );
          }
          return http.Response(
            jsonEncode([
              {
                "project_id": 7,
                "action_name": "pushed to",
                "target_type": "Project",
                "created_at": "2026-08-24T11:00:00.000Z",
                "push_data": {"commit_count": 1},
              },
              {"created_at": "invalid"},
            ]),
            200,
          );
        });

        final contributions = await ContributionService.fetchGitLab(
          "godoytristanh",
          client: client,
          now: DateTime(2026, 8, 25),
        );

        expect(requestedPages, {1, 2});
        expect(contributions, {"2026-08-24": 3});
      },
    );

    test("builds CORS-safe GitLab raw-file API URLs", () {
      final url = ContributionService.gitLabRawFileUrl(
        "https://gitlab.com/godoytristanh/dart_filetree/-/tree/main/rust_filetree",
        filePath: "lib/main.dart",
        branch: "develop",
      );

      expect(url, contains("/projects/godoytristanh%2Fdart_filetree/"));
      expect(url, contains("/repository/files/lib%2Fmain.dart/raw"));
      expect(url, endsWith("?ref=develop"));
      expect(url, isNot(contains("corsproxy.io")));
    });
  });
}
