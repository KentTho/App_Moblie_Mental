import axios from "axios";
import type { User } from "../types/user";

export const getUsers = async (): Promise<User[]> => {
  const res = await axios.get("http://localhost:8000/user/list");
  return res.data.map((u: any) => ({
    id: u.id,
    name: u.full_name || "No name",
    email: u.email,
    status: u.is_verified ? "active" : "inactive",
    joinDate: new Date(u.created_at).toISOString().split("T")[0],
    lastActive: u.last_active ? new Date(u.last_active).toISOString().split("T")[0] : null,
    notesCount: u.notes_count,
    riskLevel: u.risk_level || "unknown"
  }));
};
