from pydantic import BaseModel, Field
from typing import Annotated, Union
from typing import Optional, List, Any
from datetime import datetime
from uuid import UUID

class NoteBase(BaseModel):
    title: str
    content: Optional[str] = None # Changed to Optional[str] as it can be empty
    content_json: Optional[dict] = None  # ✅ Changed to dict for consistency
    tags: Annotated[List[str], Field(default_factory=list)]
    sentiment: Optional[str] = None # Keep sentiment as is
    emotions: Optional[List[str]] = None # ✅ NEW: Add emotions field


class NoteCreate(BaseModel):
    #user_id: UUID
    title: str
    content: str
    content_json: Optional[Any] = None  # ✅ thêm vào đây
    tags: List[str]

class NoteUpdate(BaseModel):
    title: str
    content: str
    content_json: Optional[Union[dict, list]] = None  # ✅ Sửa tại đây
    tags: List[str]

class NoteOut(BaseModel):
    id: UUID
    user_id: str
    title: str
    content: str
    tags: List[str]
    sentiment: str | None
    emotions: Optional[List[str]] = None  # ✅ THÊM DÒNG NÀY
    created_at: datetime
    updated_at: datetime

    model_config = {
        "from_attributes": True,
        "json_encoders": {
            UUID: lambda v: str(v)  # ✅ thêm dòng này
        }
    }