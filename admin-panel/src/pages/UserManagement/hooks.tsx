import { useEffect, useState } from "react";
import type { User } from "../../types/user";
import { getUsers } from "../../services/userService";

export const useUserList = () => {
  const [users, setUsers] = useState<User[]>([]);

  useEffect(() => {
    getUsers().then(setUsers).catch(console.error);
  }, []);

  return { users, setUsers };
};
