# BetweenPages API Integration Progress

## Current Status
✅ Plan approved by user  
✅ Core infrastructure ready (ApiClient, tokens)  
✅ One service example (libro_journal)  

## Phase 1: Core Setup (Execute Next)
✅ Update `lib/core/constants/api_constants.dart` - Add all 32 endpoints
✅ Extend `lib/api/api_client.dart` - Add GET/PUT/DELETE
- [ ] Create `lib/providers/api_provider.dart` - Global ApiClient  
- [ ] Create `lib/providers/auth_provider.dart` - Auth state  
- [ ] Update `lib/main.dart` - Initialize providers + auth check  

## Phase 2: Authentication (Priority)
- [ ] `lib/services/auth_service.dart`  
- [ ] `lib/screens/auth/login_screen.dart`  
- [ ] `lib/screens/auth/register_screen.dart`  

## Phase 3: Catalog Services
- [ ] `lib/services/catalog_service.dart` (Fanfic/Libro/Manga)  

## Phase 4: Journals (Fanfic/Libro/Manga)
- [ ] Extend `lib/services/libro_journal_service.dart`  
- [ ] `lib/services/fanfic_journal_service.dart`  
- [ ] `lib/services/manga_journal_service.dart`  

## Phase 5: Lists & Tags
- [ ] `lib/services/lista_service.dart`  
- [ ] `lib/services/tags_service.dart`  

## Phase 6: Full UI Integration
- [ ] Update all screens/  
- [ ] Navigation + Error handling  
- [ ] Test all 32 endpoints  

**Next Command**: Execute Phase 1
