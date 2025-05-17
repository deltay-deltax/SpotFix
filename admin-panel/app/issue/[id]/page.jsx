import { createClient } from "@/utils/supabase/server";
import { redirect } from "next/navigation";
import Link from "next/link";

export default async function IssuePage({ params }) {
  const supabase = await createClient();
  const { data: issue, error } = await supabase
    .from("issues")
    .select("*")
    .eq("id", params.id)
    .single();

  if (error) {
    console.error("Error fetching issue:", error);
    return <div>Error loading issue</div>;
  }

  async function updateStatus(formData) {
    "use server";
    const supabase = await createClient();
    const newStatus = formData.get("status");

    const { error } = await supabase
      .from("issues")
      .update({ status: newStatus })
      .eq("id", params.id);

    if (error) {
      console.error("Error updating status:", error);
      return;
    }

    redirect("/");
  }

  return (
    <div className="w-full max-w-4xl mx-auto">
      <Link href="/" className="text-blue-500 hover:underline mb-6 block">
        &larr; Back to Dashboard
      </Link>

      <div className="bg-white shadow-md rounded">
        <div className="p-6">
          <h1 className="text-2xl font-bold mb-6">{issue.title}</h1>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <div className="mb-4">
                <span className="font-semibold">Current Status:</span>
                <span
                  className="ml-2 px-2 py-1 rounded text-white"
                  style={{
                    backgroundColor: getStatusBgColor(issue.status),
                  }}
                >
                  {issue.status || "Unknown"}
                </span>
              </div>

              <div className="mb-4">
                <span className="font-semibold">Description:</span>
                <p className="mt-2">{issue.description}</p>
              </div>

              <div className="mb-4">
                <span className="font-semibold">Location:</span>
                <p className="mt-2">
                  Latitude: {issue.latitude}, Longitude: {issue.longitude}
                </p>
              </div>
            </div>

            <div>
              {issue.image_url && (
                <div className="mb-6">
                  <span className="font-semibold">Image:</span>
                  <div className="mt-2 max-h-[150px] overflow-hidden rounded">
                    <img
                      src={issue.image_url}
                      alt="Issue"
                      className="w-auto h-full object-contain"
                      style={{ maxHeight: "150px" }}
                    />
                  </div>
                </div>
              )}

              <div className="bg-gray-50 p-6 rounded border mt-4">
                <h2 className="text-lg font-semibold mb-4">Update Status</h2>
                <form action={updateStatus}>
                  <div className="mb-4">
                    <label className="block font-semibold mb-2">
                      New Status:
                    </label>
                    <select
                      name="status"
                      defaultValue={issue.status}
                      className="w-full p-2 border rounded"
                    >
                      <option value="reported">Reported</option>
                      <option value="in progress">In Progress</option>
                      <option value="resolved">Resolved</option>
                    </select>
                  </div>

                  <button
                    type="submit"
                    className="bg-pink-600 text-white w-full px-4 py-2 rounded hover:bg-pink-700"
                  >
                    Update Status
                  </button>
                </form>
              </div>
            </div>
          </div>
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
