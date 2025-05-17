import { createClient } from "@/utils/supabase/server";
import Link from "next/link";

export default async function Dashboard() {
  const supabase = await createClient();
  const { data: issues, error } = await supabase
    .from("issues")
    .select("*")
    .order("created_at", { ascending: false });

  if (error) {
    console.error("Error fetching issues:", error);
    return <div>Error loading issues</div>;
  }

  // Count issues by status (case-insensitive with null handling)
  const statusCounts = {
    reported: issues.filter(
      (issue) => issue.status?.toLowerCase() === "reported"
    ).length,
    "in progress": issues.filter(
      (issue) => issue.status?.toLowerCase() === "in progress"
    ).length,
    resolved: issues.filter(
      (issue) => issue.status?.toLowerCase() === "resolved"
    ).length,
    total: issues.length,
  };

  return (
    <div className="w-full">
      <h1 className="text-3xl font-bold mb-6">SpotFix Government Dashboard</h1>

      {/* Stats Cards - 2 in a row */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
        <div className="bg-white shadow-md p-6">
          <h2 className="text-gray-600 text-sm font-semibold">Total Issues</h2>
          <p className="text-4xl font-bold mt-2">{statusCounts.total}</p>
        </div>
        <div className="bg-white shadow-md p-6">
          <h2 className="text-orange-500 text-sm font-semibold">Reported</h2>
          <p className="text-4xl font-bold mt-2">{statusCounts.reported}</p>
        </div>
        <div className="bg-white shadow-md p-6">
          <h2 className="text-blue-500 text-sm font-semibold">In Progress</h2>
          <p className="text-4xl font-bold mt-2">
            {statusCounts["in progress"]}
          </p>
        </div>
        <div className="bg-white shadow-md p-6">
          <h2 className="text-green-500 text-sm font-semibold">Resolved</h2>
          <p className="text-4xl font-bold mt-2">{statusCounts.resolved}</p>
        </div>
      </div>

      {/* Issues Table - Full width */}
      <div className="w-full bg-white shadow-md">
        <div className="p-4 border-b">
          <h2 className="text-xl font-semibold">Recent Reports</h2>
        </div>
        <div className="overflow-x-auto w-full">
          <table className="min-w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="py-3 px-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Title
                </th>
                <th className="py-3 px-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Description
                </th>
                <th className="py-3 px-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="py-3 px-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Reported On
                </th>
                <th className="py-3 px-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {issues.map((issue) => (
                <tr key={issue.id}>
                  <td className="py-3 px-4">{issue.title}</td>
                  <td className="py-3 px-4">
                    {issue.description?.substring(0, 50)}...
                  </td>
                  <td className="py-3 px-4">
                    <span
                      className="px-2 py-1 rounded text-white"
                      style={{
                        backgroundColor: getStatusBgColor(issue.status),
                      }}
                    >
                      {issue.status || "Unknown"}
                    </span>
                  </td>
                  <td className="py-3 px-4">{formatDate(issue.created_at)}</td>
                  <td className="py-3 px-4">
                    <Link
                      href={`/issue/${issue.id}`}
                      className="bg-pink-600 hover:bg-pink-700 text-white py-2 px-4 rounded"
                    >
                      Manage
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

function getStatusBgColor(status) {
  const statusValue = status?.toLowerCase() || "unknown";

  switch (statusValue) {
    case "reported":
      return "#f97316"; // orange-500
    case "in progress":
      return "#3b82f6"; // blue-500
    case "resolved":
      return "#22c55e"; // green-500
    default:
      return "#6b7280"; // gray-500
  }
}

function formatDate(dateString) {
  if (!dateString) return "";
  const date = new Date(dateString);
  return date.toLocaleDateString();
}
