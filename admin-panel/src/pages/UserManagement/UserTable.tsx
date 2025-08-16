import { Badge } from "../../components/ui/badge";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "../../components/ui/table";
import { Button } from "../../components/ui/button";
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "../../components/ui/dropdown-menu";
import { MoreHorizontal, Shield, Ban, Mail } from "lucide-react";
import type { User } from "../../types/user";
import { getRiskBadgeColor, getStatusBadgeColor } from "../../utils/badgeColor";

interface Props {
  users: User[];
}

export default function UserTable({ users }: Props) {
  return (
    <div className="rounded-md border">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>User</TableHead>
            <TableHead>Status</TableHead>
            <TableHead>Join Date</TableHead>
            <TableHead>Last Active</TableHead>
            <TableHead>Notes</TableHead>
            <TableHead>Risk Level</TableHead>
            <TableHead className="text-right">Actions</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {users.map((user) => (
            <TableRow key={user.id}>
              <TableCell>
                <div>
                  <div className="font-medium">{user.name}</div>
                  <div className="text-sm text-gray-500">{user.email}</div>
                </div>
              </TableCell>
              <TableCell>
                <Badge className={getStatusBadgeColor(user.status)}>{user.status}</Badge>
              </TableCell>
              <TableCell>{user.joinDate}</TableCell>
              <TableCell>{user.lastActive}</TableCell>
              <TableCell>{user.notesCount}</TableCell>
              <TableCell>
                <Badge className={getRiskBadgeColor(user.riskLevel)}>{user.riskLevel}</Badge>
              </TableCell>
              <TableCell className="text-right">
                <DropdownMenu>
                  <DropdownMenuTrigger asChild>
                    <Button variant="ghost" className="h-8 w-8 p-0">
                      <MoreHorizontal className="h-4 w-4" />
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="end">
                    <DropdownMenuItem><Shield className="mr-2 h-4 w-4" />View Profile</DropdownMenuItem>
                    <DropdownMenuItem><Mail className="mr-2 h-4 w-4" />Send Message</DropdownMenuItem>
                    <DropdownMenuItem className="text-red-600"><Ban className="mr-2 h-4 w-4" />Suspend User</DropdownMenuItem>
                  </DropdownMenuContent>
                </DropdownMenu>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}
