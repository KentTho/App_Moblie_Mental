import * as React from "react";

type TabsContextValue = {
  active: string;
  setActive: (val: string) => void;
};

const TabsCtx = React.createContext<TabsContextValue | null>(null);

type TabsProps = {
  value: string;
  onValueChange?: (val: string) => void;
  children: React.ReactNode;
  className?: string;
};

export function Tabs({ value, onValueChange, children, className }: TabsProps) {
  const [active, _setActive] = React.useState(value);
  const setActive = (val: string) => {
    _setActive(val);
    onValueChange?.(val);
  };
  return (
    <TabsCtx.Provider value={{ active, setActive }}>
      <div className={className ?? ""}>{children}</div>
    </TabsCtx.Provider>
  );
}

type TabsListProps = {
  children: React.ReactNode;
  className?: string;
};

export function TabsList({ children, className }: TabsListProps) {
  // dùng màu Tailwind chuẩn để không phụ thuộc token của shadcn
  return (
    <div
      className={`inline-flex h-10 items-center justify-center rounded-md bg-gray-100 p-1 text-gray-600 ${className ?? ""}`}
    >
      {children}
    </div>
  );
}

type TabsTriggerProps = {
  value: string;
  children: React.ReactNode;
  className?: string;
};

export function TabsTrigger({ value, children, className }: TabsTriggerProps) {
  const ctx = React.useContext(TabsCtx);
  if (!ctx) throw new Error("TabsTrigger must be used within <Tabs>");
  const isActive = ctx.active === value;

  return (
    <button
      onClick={() => ctx.setActive(value)}
      className={`inline-flex items-center justify-center whitespace-nowrap rounded px-3 py-1.5 text-sm font-medium transition-all
      ${isActive ? "bg-white text-gray-900 shadow" : "text-gray-600 hover:text-gray-900"} ${className ?? ""}`}
    >
      {children}
    </button>
  );
}

type TabsContentProps = {
  value: string;
  children: React.ReactNode;
  className?: string;
};

export function TabsContent({ value, children, className }: TabsContentProps) {
  const ctx = React.useContext(TabsCtx);
  if (!ctx) return null;
  if (ctx.active !== value) return null;
  return <div className={`mt-2 ${className ?? ""}`}>{children}</div>;
}
