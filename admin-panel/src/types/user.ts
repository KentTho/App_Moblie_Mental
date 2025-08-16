export interface User {
  id: string;
  name: string;
  email: string;
  status: "active" | "inactive";
  joinDate: string;
  lastActive: string | null;
  notesCount: number;
  riskLevel: "low" | "medium" | "high" | "unknown";
}
