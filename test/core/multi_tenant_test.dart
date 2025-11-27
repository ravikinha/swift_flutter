import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/core/multi_tenant.dart';
import 'package:swift_flutter/core/rx.dart';

class TestService {
  final String name;
  TestService(this.name);
}

void main() {
  group('TenantAwareStore', () {
    late TenantAwareStore store;

    setUp(() {
      store = TenantAwareStore();
    });

    tearDown(() {
      store.clearAll();
    });

    test('should set and get current tenant', () {
      store.setTenant('tenant1');
      expect(store.currentTenantId, 'tenant1');
    });

    test('should create tenant context automatically', () {
      store.setTenant('tenant1');
      expect(store.currentContext, isNotNull);
      expect(store.currentContext!.tenantId, 'tenant1');
    });

    test('should set tenant with custom context', () {
      final context = TenantContext(
        tenantId: 'tenant1',
        name: 'Tenant One',
        config: {'feature': 'enabled'},
      );

      store.setTenant('tenant1', context: context);
      expect(store.currentContext!.name, 'Tenant One');
      expect(store.currentContext!.config['feature'], 'enabled');
    });

    test('should isolate services per tenant', () {
      store.setTenant('tenant1');
      store.register(TestService('Service for Tenant 1'));

      store.setTenant('tenant2');
      store.register(TestService('Service for Tenant 2'));

      store.setTenant('tenant1');
      final service1 = store.get<TestService>();
      expect(service1.name, 'Service for Tenant 1');

      store.setTenant('tenant2');
      final service2 = store.get<TestService>();
      expect(service2.name, 'Service for Tenant 2');
    });

    test('should isolate state per tenant', () {
      store.setTenant('tenant1');
      final counter1 = swift(0);
      store.registerState('counter', counter1);

      store.setTenant('tenant2');
      final counter2 = swift(10);
      store.registerState('counter', counter2);

      store.setTenant('tenant1');
      expect(store.getState<int>('counter').value, 0);

      store.setTenant('tenant2');
      expect(store.getState<int>('counter').value, 10);
    });

    test('should throw error if no tenant set', () {
      expect(() => store.register(TestService('test')), throwsStateError);
      expect(() => store.get<TestService>(), throwsStateError);
    });

    test('should clear tenant data', () {
      store.setTenant('tenant1');
      store.register(TestService('test'));

      store.clearTenant('tenant1');
      expect(store.hasTenant('tenant1'), isFalse);
    });

    test('should clear all tenants', () {
      store.setTenant('tenant1');
      store.setTenant('tenant2');

      store.clearAll();
      expect(store.getTenantCount(), 0);
      expect(store.currentTenantId, isNull);
    });

    test('should get all tenant IDs', () {
      store.setTenant('tenant1');
      store.setTenant('tenant2');
      store.setTenant('tenant3');

      final ids = store.getAllTenantIds();
      expect(ids.length, 3);
      expect(ids, contains('tenant1'));
      expect(ids, contains('tenant2'));
      expect(ids, contains('tenant3'));
    });

    test('should check if tenant exists', () {
      store.setTenant('tenant1');
      expect(store.hasTenant('tenant1'), isTrue);
      expect(store.hasTenant('tenant2'), isFalse);
    });

    test('should update tenant context', () {
      store.setTenant('tenant1');

      final newContext = TenantContext(
        tenantId: 'tenant1',
        name: 'Updated Name',
      );
      store.updateTenantContext('tenant1', newContext);

      expect(store.getTenantContext('tenant1')!.name, 'Updated Name');
    });

    test('should clear current tenant', () {
      store.setTenant('tenant1');
      store.clearCurrentTenant();
      expect(store.currentTenantId, isNull);
    });
  });

  group('TenantScopedRx', () {
    late TenantScopedRx<int> scopedState;

    setUp(() {
      scopedState = TenantScopedRx<int>(() => 0);
      tenantStore.clearAll();
    });

    test('should create isolated state per tenant', () {
      final state1 = scopedState.getForTenant('tenant1');
      final state2 = scopedState.getForTenant('tenant2');

      state1.value = 10;
      state2.value = 20;

      expect(state1.value, 10);
      expect(state2.value, 20);
    });

    test('should get current tenant state', () {
      tenantStore.setTenant('tenant1');
      scopedState.current.value = 100;

      tenantStore.setTenant('tenant2');
      scopedState.current.value = 200;

      tenantStore.setTenant('tenant1');
      expect(scopedState.current.value, 100);
    });

    test('should throw error if no tenant set', () {
      expect(() => scopedState.current, throwsStateError);
    });

    test('should clear tenant state', () {
      scopedState.getForTenant('tenant1').value = 10;
      scopedState.clearTenant('tenant1');

      final newState = scopedState.getForTenant('tenant1');
      expect(newState.value, 0); // Reset to initial value
    });

    test('should clear all tenant states', () {
      scopedState.getForTenant('tenant1');
      scopedState.getForTenant('tenant2');

      scopedState.clearAll();
      expect(scopedState.getTenantIds().length, 0);
    });

    test('should get all tenant IDs', () {
      scopedState.getForTenant('tenant1');
      scopedState.getForTenant('tenant2');

      final ids = scopedState.getTenantIds();
      expect(ids.length, 2);
      expect(ids, contains('tenant1'));
      expect(ids, contains('tenant2'));
    });
  });

  group('TenantContext', () {
    test('should serialize to JSON', () {
      final context = TenantContext(
        tenantId: 'tenant1',
        name: 'Test Tenant',
        config: {'key': 'value'},
      );

      final json = context.toJson();
      expect(json['tenantId'], 'tenant1');
      expect(json['name'], 'Test Tenant');
      expect(json['config'], {'key': 'value'});
    });

    test('should deserialize from JSON', () {
      final json = {
        'tenantId': 'tenant1',
        'name': 'Test Tenant',
        'config': {'key': 'value'},
        'createdAt': DateTime.now().toIso8601String(),
      };

      final context = TenantContext.fromJson(json);
      expect(context.tenantId, 'tenant1');
      expect(context.name, 'Test Tenant');
      expect(context.config['key'], 'value');
    });
  });

  group('TenantConfig', () {
    setUp(() {
      tenantStore.clearAll();
    });

    test('should create tenant context', () {
      final context = TenantConfig.create(
        tenantId: 'tenant1',
        name: 'Test',
        config: {'feature': 'enabled'},
      );

      expect(context.tenantId, 'tenant1');
      expect(context.name, 'Test');
      expect(context.config['feature'], 'enabled');
    });

    test('should get and set config values', () {
      tenantStore.setTenant('tenant1');
      TenantConfig.set('feature', 'enabled');

      final value = TenantConfig.get<String>('feature');
      expect(value, 'enabled');
    });

    test('should return default value if key not found', () {
      tenantStore.setTenant('tenant1');
      final value = TenantConfig.get<String>('missing', defaultValue: 'default');
      expect(value, 'default');
    });

    test('should check if config key exists', () {
      tenantStore.setTenant('tenant1');
      TenantConfig.set('key', 'value');

      expect(TenantConfig.has('key'), isTrue);
      expect(TenantConfig.has('missing'), isFalse);
    });

    test('should throw error if no tenant set', () {
      expect(() => TenantConfig.set('key', 'value'), throwsStateError);
    });
  });
}

